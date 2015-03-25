//
//  OrderStatusViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>
#import <RNTimer.h>
#import <Bolts.h>
#import "NSValue+CLLocationCoordinate2D.h"
#import "OrderStatusViewController.h"
#import "OrderStatusDetailView.h"
#import "ParseAPI.h"
#import "ReviewViewController.h"
#import "TKHeader.h"
#import "DateUtils.h"

static const NSTimeInterval kUpdateInterval = 5.0;
static const float kMapZoomMargin = 1.8;
static const float kEtaFudgeFactor = 1.5;

@interface OrderStatusViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet TKHeader *headerView;
@property (weak, nonatomic) IBOutlet OrderStatusDetailView *orderSummaryView;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *relativeETALabel;
@property (weak, nonatomic) IBOutlet UILabel *absoluteETALabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) BOOL didStartRouteCalculation;
@property (strong, nonatomic) NSDate *estimatedDeliveryTime;
@property (strong, nonatomic) RNTimer *updateTimer;
@property (strong, nonatomic) id<MKAnnotation> deliveryAddressAnnotation;
@property (strong, nonatomic) id<MKAnnotation> driverLocationAnnotation;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSTimeInterval timeOfLastUpdate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewConstraint;
@property (nonatomic) CGFloat originalInfoViewOffset;

@end

@implementation OrderStatusViewController

+ (NSDateFormatter *)timeFormatter {
    static NSDateFormatter *timeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateStyle = NSDateFormatterNoStyle;
        timeFormatter.timeStyle = NSDateFormatterShortStyle;
    });
    return timeFormatter;
}

+ (TTTTimeIntervalFormatter *)timeIntervalFormatter {
    static TTTTimeIntervalFormatter *timeIntervalFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    });
    return timeIntervalFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *backButton = [[UIButton alloc] initWithFrame:self.headerView.leftView.bounds];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"Futura" size:17];
    [backButton addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    backButton.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    [self.headerView.leftView addSubview:backButton];
                                  
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.headerView.titleView.bounds];
    titleLabel.text = @"Delivery Status";
    titleLabel.font = [UIFont fontWithName:@"Futura" size:24];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    [self.headerView.titleView addSubview:titleLabel];
    
    self.mapView.delegate = self;
    if (self.order) {
        [self startTimer];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Review" style:UIBarButtonItemStylePlain target:self action:@selector(onReview)];
    }
    [self updateSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.reportLocationAsDriverLocation) {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            self.locationManager.delegate = self;
        }
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.reportLocationAsDriverLocation) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOrder:(Order *)order {
    _order = order;
    
    [self clearMap];
    [self startTimer];
    [self updateSubviews];
}

- (void)updateSubviews {
    self.orderSummaryView.order = self.order;
    [self.view setNeedsLayout];
}

- (void)displayMap {
    MKDirectionsRequest *dirReq = [[MKDirectionsRequest alloc] init];
    dirReq.source = self.order.driverLocationMapItem;
    
    [[[[[self geocodeString:self.order.deliveryAddress] continueWithSuccessBlock:^id(BFTask *task) {
        MKMapItem *mapItem = task.result;
        NSLog(@"mapItem = %@", mapItem);
        dirReq.destination = mapItem;
        self.deliveryAddressAnnotation = mapItem.placemark;
        [self.mapView addAnnotation:self.deliveryAddressAnnotation];
        [self updateMapRegion];
        return [self calculateRouteWithRequest:dirReq];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        MKRoute *route = task.result;
        self.estimatedDeliveryTime = [NSDate dateWithTimeIntervalSinceNow:route.expectedTravelTime * kEtaFudgeFactor];
        return route;
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
//        MKRoute *route = task.result;
//        [self updateMapViewWithRoute:route];
        [self updateEta];
        self.infoView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.infoView.alpha = 1;
            self.mapView.alpha = 1;
        }];
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        if (task.isFaulted) {
            NSLog(@"Error during displayMap: %@", task.error);
        }
        return nil;
    }];
}

- (BFTask *)geocodeString:(NSString *)string {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:string completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error during geocodeAddressString: %@", error);
            [taskSource setError:error];
        } else {
            MKPlacemark *firstMatch = placemarks[0];
            NSLog(@"geocodeAddressString first match: %@ @ %@", firstMatch.name, firstMatch.location);
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:firstMatch]];
            [taskSource setResult:mapItem];
        }
    }];
    return taskSource.task;
}

- (BFTask *)calculateRouteWithRequest:(MKDirectionsRequest *)dirReq {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    NSLog(@"calculating directions for request: %@", dirReq);
    [[[MKDirections alloc] initWithRequest:dirReq] calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error from calculateDirections: %@", error);
            [taskSource setError:error];
        } else {
            MKRoute *route = response.routes[0];
            NSLog(@"Route = %@", route);
            [taskSource setResult:route];
        }
    }];
    return taskSource.task;
}

- (void)updateMapViewWithRoute:(MKRoute *)route {
    self.mapView.region = [self regionForRoute:route];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlay:route.polyline];
}

- (MKCoordinateRegion)regionForRoute:(MKRoute *)route {
    NSUInteger pointCount = route.polyline.pointCount;
    MKMapPoint *points = route.polyline.points;
    NSMutableArray *coordinates = [NSMutableArray arrayWithCapacity:pointCount];
    for (int i = 0; i < pointCount; i++) {
        CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(points[i]);
        [coordinates addObject:[NSValue valueWithCoordinate:coordinate]];
    }
    return [self regionForCoordinates:coordinates];
}

- (MKCoordinateRegion)regionForCoordinates:(NSArray *)coordinates {
    /* Add 360 degrees so we can properly find the bounding box without sign problems */
    CLLocationCoordinate2D nwCorner = [coordinates.firstObject coordinateValue];
    nwCorner.latitude += 360;
    nwCorner.longitude += 360;
    CLLocationCoordinate2D seCorner = nwCorner;
    
    for (NSValue *coordinateValue in coordinates) {
        CLLocationCoordinate2D coordinate = coordinateValue.coordinateValue;
        coordinate.latitude += 360;
        coordinate.longitude += 360;
        if (coordinate.latitude  < seCorner.latitude)  seCorner.latitude  = coordinate.latitude;
        if (coordinate.latitude  > nwCorner.latitude)  nwCorner.latitude  = coordinate.latitude;
        if (coordinate.longitude < nwCorner.longitude) nwCorner.longitude = coordinate.longitude;
        if (coordinate.longitude > seCorner.longitude) seCorner.longitude = coordinate.longitude;
    }
    
    /* remove the 360 degree offset we added earlier */
    CLLocationCoordinate2D center =
        CLLocationCoordinate2DMake(
                                   (nwCorner.latitude + seCorner.latitude)   / 2 - 360,
                                   (nwCorner.longitude + seCorner.longitude) / 2 - 360);
    MKCoordinateSpan span =
        MKCoordinateSpanMake(
                             (nwCorner.latitude - seCorner.latitude) * kMapZoomMargin,
                             (seCorner.longitude - nwCorner.longitude) * kMapZoomMargin);
    
    return MKCoordinateRegionMake(center, span);
}

#pragma mark UIMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *reuseIdentifier;
    NSString *imageName;
    if (annotation == self.driverLocationAnnotation) {
        reuseIdentifier = @"driverLocationAnnotation";
        imageName = @"map-car-icon";
    } else if (annotation == self.deliveryAddressAnnotation) {
        reuseIdentifier = @"deliveryAddressAnnotation";
        imageName = @"map-pointer-icon";
    } else {
        NSLog(@"Unknown annotation in viewForAnnotation");
    }

    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        annotationView.image = [UIImage imageNamed:imageName];
    }

    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.lineWidth = 3;
    renderer.strokeColor = [UIColor blueColor];
    return renderer;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /* keep network activity low by only updating occassionally */
    if (self.timeOfLastUpdate < CACurrentMediaTime() - kUpdateInterval) {
        [[ParseAPI getInstance] updateOrder:self.order withDriverLocation:locations.lastObject];
        [self updateDriverLocation];
        self.timeOfLastUpdate = CACurrentMediaTime();
    }
}

#pragma mark RNTimer

- (void)startTimer {
    if (!self.updateTimer) {
        [self refresh];
        self.updateTimer = [RNTimer repeatingTimerWithTimeInterval:kUpdateInterval block:^{
            [self refresh];
        }];
    }
}

- (void)stopTimer {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

#pragma mark Refresh

- (void)clearMap {
    self.didStartRouteCalculation = NO;
    self.estimatedDeliveryTime = nil;
    self.driverLocationAnnotation = nil;
    self.deliveryAddressAnnotation = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)refresh {
    NSLog(@"Refreshing");
    [[self.order fetchInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        if (self.order.driverLocation && !self.didStartRouteCalculation) {
            self.didStartRouteCalculation = YES;
            [self displayMap];
        } else if (self.order.driverLocation) {
            [self updateDriverLocation];
        }
        if (self.estimatedDeliveryTime) {
            [self updateEta];
        }

        return nil;
    }];
}

- (void)updateDriverLocation {
    if (!self.driverLocationAnnotation) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = @"Your Order";
        annotation.coordinate = self.order.driverLocationMapItem.placemark.location.coordinate;
        [self.mapView addAnnotation:annotation];
        self.driverLocationAnnotation = annotation;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.driverLocationAnnotation.coordinate = self.order.driverLocationMapItem.placemark.location.coordinate;
    }];
    [self updateMapRegion];
}

- (void)updateEta {
    self.absoluteETALabel.text = [[self.class timeFormatter] stringFromDate:self.estimatedDeliveryTime];
    self.relativeETALabel.text = [DateUtils approximateTimeStringFromInterval:[self.estimatedDeliveryTime timeIntervalSinceNow]];
}

- (void)updateMapRegion {
    if (self.driverLocationAnnotation && self.deliveryAddressAnnotation) {
        [UIView animateWithDuration:0.5 animations:^{
            self.mapView.region = [self regionForCoordinates:@[
                                                               [NSValue valueWithCoordinate:self.driverLocationAnnotation.coordinate],
                                                               [NSValue valueWithCoordinate:self.deliveryAddressAnnotation.coordinate]]];
        }];
    }
}

#pragma mark - Button Actions

- (void)onBackButton {
    [self.delegate orderStatusViewControllerShouldBeDismissed:self];
}

- (void)onReview {
    ReviewViewController *rvc = [[ReviewViewController alloc] init];
    rvc.order = self.order;
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark - Gesture Actions

- (IBAction)onInfoViewTap:(UITapGestureRecognizer *)sender {
    if (!self.originalInfoViewOffset) {
        self.originalInfoViewOffset = self.infoViewConstraint.constant;
    }
    CGFloat newOffset = (self.infoViewConstraint.constant == self.originalInfoViewOffset) ? -CGRectGetHeight(self.infoView.bounds) : self.originalInfoViewOffset;
    self.infoViewConstraint.constant = newOffset;
    [UIView animateWithDuration:0.3 animations:^{
        [self.infoView.superview layoutIfNeeded];
    }];
}

@end
