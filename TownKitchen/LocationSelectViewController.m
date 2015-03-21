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

@interface LocationSelectViewController () <MKMapViewDelegate, CLLocationManagerDelegate, AddressInputViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *setAddressButton;
@property (weak, nonatomic) IBOutlet UIView *centerIndicatorView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *addressString;
@property (assign, nonatomic) BOOL didMoveToCurrentLocation;
@property (assign, nonatomic) BOOL didCompleteFirstRender;

@property NSTimer *mapRegionChangedTimer;  // timer to avoid reverse gecoding too often

@end

@implementation LocationSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}


#pragma mark Life Cycle Methods

- (void) dealloc
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Custom Setters


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
    
    // Customize navigation bar
    self.navigationController.navigationBar.translucent = NO;
}

- (void)runDelayedSearch {
    [self.mapRegionChangedTimer invalidate];
    self.mapRegionChangedTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                              target:self
                                                            selector:@selector(updateAddressFromMapCenter)
                                                            userInfo:nil
                                                             repeats:NO];
}

- (void)updateAddressFromMapCenter {
    NSLog(@"updating address from map center");
    self.addressLabel.text = @"Updating location...";
    [[LMGeocoder sharedInstance]
     reverseGeocodeCoordinate:self.mapView.centerCoordinate
     service:kLMGeocoderGoogleService
     completionHandler:^(LMAddress *address, NSError *error) {
         if (address && !error) {
             self.addressString = address.formattedAddress;
             if (address.streetNumber) {
                 self.addressLabel.text = [NSString stringWithFormat:@"%@ %@", address.streetNumber, address.route];
             }
             else if (address.route) {
                 self.addressLabel.text = [NSString stringWithFormat:@"%@", address.route];
             }
             else {
                 self.addressLabel.text = @"Unknown address";
             }
             
         }
         else {
             NSLog(@"Error: %@", error.description);
             self.addressLabel.text = @"Unable to find address";
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

#pragma mark MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.didCompleteFirstRender) {
        [self runDelayedSearch];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.mapRegionChangedTimer invalidate];
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
}

#pragma mark AddressInputViewController Methods

- (void)addressInputViewController:(AddressInputViewController *)addressInputViewController didSelectPlaceDetails:(GKPlaceDetails *)details {
    self.addressString = details.formattedAddress;
    self.addressLabel.text = [NSString stringWithFormat:@"%@ %@", details.streetNumber, details.route];
    [self moveToInputAddress];
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
    [self.delegate locationSelectViewController:self didSelectAddress:self.addressString];
}

- (IBAction)onAddressViewTap:(id)sender {
    AddressInputViewController *avc = [[AddressInputViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    
    avc.initialSearchTerm = self.addressString;
    avc.currentLocation = self.currentLocation;
    avc.delegate = self;
    
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark System Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
