//
//  LocationSelectViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "LocationSelectViewController.h"
#import "AddressInputViewController.h"
#import <GoogleKit.h>
#import <MapKit/MapKit.h>
#import <LMGeocoder.h>
#import <UIView+MTAnimation.h>

@interface LocationSelectViewController () <MKMapViewDelegate, CLLocationManagerDelegate, AddressInputViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *setAddressButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *addressString;
@property (strong, nonatomic) NSString *currentAddressLabelString;
@property (assign, nonatomic) BOOL didMoveToCurrentLocation;
@property (assign, nonatomic) BOOL didCompleteFirstRender;

@property NSTimer *mapRegionChangedTimer;  // timer to avoid reverse gecoding too often

@end

@implementation LocationSelectViewController

#pragma mark Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.locationManager) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.didCompleteFirstRender) {
        [self runDelayedSearch];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.mapRegionChangedTimer invalidate];
    if (![self.currentAddressLabelString isEqualToString:@"Updating location..."]) {
        [self fadeAddressLabelToString:@"Updating location..."];
    }
}


- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    // update map address on first load
    if (!self.didCompleteFirstRender) {
        self.didCompleteFirstRender = YES;
        [self updateAddressFromMapCenter];
    }
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    if (!self.didMoveToCurrentLocation) {
        [self moveToCoordinates:self.currentLocation.coordinate withVisibleDistance:200];
        self.didMoveToCurrentLocation = YES;
    }
    if (self.currentLocation.horizontalAccuracy < 10) {
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark AddressInputViewController Methods

- (void)addressInputViewController:(AddressInputViewController *)addressInputViewController didSelectPlaceDetails:(GKPlaceDetails *)details {
    self.addressString = details.formattedAddress;
    self.addressLabel.text = [NSString stringWithFormat:@"%@ %@", details.streetNumber, details.route];
    [self moveToInputAddress];
}

- (void)addressInputViewController:(AddressInputViewController *)addressInputViewController shouldDismissAddressInputNavigationController:(UINavigationController *)navigationController {
    [self hideViewControllerAnimateToBottom:navigationController];
}

#pragma mark Actions

- (IBAction)onLocationButton:(id)sender {
    [self moveToCoordinates:self.mapView.userLocation.coordinate withSpan:self.mapView.region.span];
}

- (IBAction)onSetAddress:(id)sender {
    if ([self.addressString length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Address not set" message:@"Please select a valid location" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSLog(@"Setting address to: %@", self.addressString);
    [self.delegate locationSelectViewController:self didSelectAddress:self.addressString withShortString:self.addressLabel.text];
}

- (IBAction)onInputAddressButtonTapped:(UIButton *)sender {
    AddressInputViewController *avc = [[AddressInputViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    
    avc.initialSearchTerm = self.addressString;
    avc.currentLocation = self.currentLocation;
    avc.delegate = self;
    
    [self displayViewControllerAnimatedFromBottom:nvc];
    [self unhighlightAddressLabel];
}

- (IBAction)onInputAddressButtonTouchDown:(UIButton *)sender {
    [self highlightAddressLabel];
}

- (IBAction)onInputAddressButtonTouchDragOutside:(UIButton *)sender {
    [self unhighlightAddressLabel];
}

#pragma mark Private Methods

- (void)setup {
    self.addressString = [[NSString alloc] init];
    self.addressLabel.text = @"Updating location...";
    
    // Set up mapkit
    self.mapView.delegate = self;
    
    // Set up location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // add shadow to location button
    self.locationButton.layer.masksToBounds = NO;
    self.locationButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.locationButton.layer.shadowOpacity = 0.3;
    self.locationButton.layer.shadowRadius = 1.5f;
    self.locationButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)runDelayedSearch {
    [self.mapRegionChangedTimer invalidate];
    self.mapRegionChangedTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                                  target:self
                                                                selector:@selector(updateAddressFromMapCenter)
                                                                userInfo:nil
                                                                 repeats:NO];
}

- (void)updateAddressFromMapCenter {
    [[LMGeocoder sharedInstance]
     reverseGeocodeCoordinate:self.mapView.centerCoordinate
     service:kLMGeocoderGoogleService
     completionHandler:^(LMAddress *address, NSError *error) {
         if (address && !error) {
             self.addressString = address.formattedAddress;
             if (address.streetNumber) {
                 [self fadeAddressLabelToString:[NSString stringWithFormat:@"%@ %@", address.streetNumber, address.route]];
             }
             else if (address.route) {
                 [self fadeAddressLabelToString:[NSString stringWithFormat:@"%@", address.route]];
             }
             else {
                 [self fadeAddressLabelToString:@"Unknown address"];
             }
             
         }
         else {
             NSLog(@"Error: %@", error.description);
             [self fadeAddressLabelToString:@"Unable to find address"];
         }
     }];
}

- (void)moveToInputAddress {
    [[LMGeocoder sharedInstance]
     geocodeAddressString:self.addressString
     service:kLMGeocoderGoogleService
     completionHandler:^(LMAddress *address, NSError *error) {
         if (address && !error) {
             NSLog(@"Moving to address: %@, with coordinate: (%f, %f)", self.addressString, address.coordinate.latitude, address.coordinate.longitude);
             [self moveToCoordinates:address.coordinate withSpan:self.mapView.region.span];
         }
         else {
             NSLog(@"Error: %@", error.description);
         }
     }];
}

- (void)moveToCoordinates:(CLLocationCoordinate2D)coordinate withVisibleDistance:(CLLocationDistance)distance {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)moveToCoordinates:(CLLocationCoordinate2D)coordinate withSpan:(MKCoordinateSpan)span {
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)highlightAddressLabel {
    [UIView transitionWithView:self.addressLabel duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.addressLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    } completion:nil];
}

- (void)unhighlightAddressLabel {
    [UIView transitionWithView:self.addressLabel duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.addressLabel setTextColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
    } completion:nil];
}

- (void)displayViewControllerAnimatedFromBottom:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    
    // define initial and final frames
    CGRect finalFrame = [self frameForModalViewController];
    CGRect initialFrame = finalFrame;
    initialFrame.origin.y += initialFrame.size.height;
    viewController.view.frame = initialFrame;
    
    [self.view addSubview:viewController.view];
    
    // set shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewController.view.bounds];
    viewController.view.layer.masksToBounds = NO;
    viewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    viewController.view.layer.shadowRadius = 6;
    viewController.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    viewController.view.layer.shadowOpacity = 0.3;
    viewController.view.layer.shadowPath = shadowPath.CGPath;
    
    // animate transition
    [UIView mt_animateWithViews:@[viewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         viewController.view.frame = finalFrame;
                     } completion:^{
                         // complete the transition
                         [viewController didMoveToParentViewController:self];
                     }];
}

- (void)hideViewControllerAnimateToBottom:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    
    CGRect finalFrame = [self frameForModalViewController];
    finalFrame.origin.y += finalFrame.size.height;
    
    [UIView mt_animateWithViews:@[viewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         viewController.view.frame = finalFrame;
                     } completion:^{
                         [viewController.view removeFromSuperview];
                         [viewController removeFromParentViewController];
                     }];
}

- (CGRect)frameForModalViewController {
    return self.view.bounds;
}

- (void)fadeAddressLabelToString:(NSString *)string {
    self.currentAddressLabelString = string;
    [self.addressLabel.layer removeAllAnimations];
    NSTimeInterval duration = 0.4f;
    [UIView animateWithDuration:duration / 2.0
                     animations:^{
                         self.addressLabel.layer.opacity = 0.0;
                     } completion:^(BOOL finished) {
                         self.addressLabel.text = self.currentAddressLabelString;
                         [UIView animateWithDuration:duration / 2.0
                                          animations:^{
                                              self.addressLabel.layer.opacity = 1.0;
                                          } completion:^(BOOL finished) {
                                              nil;
                                          }];
                     }];
}

@end
