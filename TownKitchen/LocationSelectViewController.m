//
//  LocationSelectViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "LocationSelectViewController.h"
#import <MapKit/MapKit.h>
#import <LMGeocoder.h>

@interface LocationSelectViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *setAddressButton;
@property (weak, nonatomic) IBOutlet UIView *centerIndicatorView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (assign, nonatomic) BOOL didMoveToCurrentLocation;

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

#pragma mark Private Methods

- (void)setup {
    self.didMoveToCurrentLocation = 0;
    
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

- (void)updateAddressFromMapCenter {
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:self.mapView.centerCoordinate
                                                  service:kLMGeocoderGoogleService
                                        completionHandler:^(LMAddress *address, NSError *error) {
                                            if (address && !error) {
                                                NSLog(@"Address: %@", address.formattedAddress);
                                                self.addressTextField.text = address.formattedAddress;
                                                [self.addressTextField resignFirstResponder];
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

#pragma mark MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    NSLog(@"new center coordinate: (%f, %f)", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    [self updateAddressFromMapCenter];
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    if (!self.didMoveToCurrentLocation) {
        [self moveToCoordinates:self.currentLocation.coordinate withVisibleDistance:200];
        self.didMoveToCurrentLocation = YES;
    }
}

#pragma mark Actions

- (IBAction)onLocationButton:(id)sender {
    [self moveToCoordinates:self.mapView.userLocation.coordinate withVisibleDistance:800];
}

- (IBAction)onGetCoordinates:(id)sender {
    [[LMGeocoder sharedInstance] geocodeAddressString:self.addressTextField.text
                                              service:kLMGeocoderGoogleService
                                    completionHandler:^(LMAddress *address, NSError *error) {
                                        if (address && !error) {
                                            NSLog(@"Moving to address: %@, with coordinate: (%f, %f)", self.addressTextField.text, address.coordinate.latitude, address.coordinate.longitude);
                                            [self moveToCoordinates:address.coordinate withVisibleDistance:200];
                                        }
                                        else {
                                            NSLog(@"Error: %@", error.description);
                                        }
                                    }];
}

#pragma mark System Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
