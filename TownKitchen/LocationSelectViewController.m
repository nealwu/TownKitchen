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

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

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
}

- (void)moveToCoordinates:(CLLocationCoordinate2D)coordinate withVisibleDistance:(CLLocationDistance)distance {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

#pragma mark MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"new center coordinate: (%f, %f)", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
}

#pragma mark Actions

- (IBAction)onLocationButton:(id)sender {
    [self moveToCoordinates:self.mapView.userLocation.coordinate withVisibleDistance:800];
}

- (IBAction)onGetAddress:(id)sender {
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:self.mapView.centerCoordinate
                                                  service:kLMGeocoderGoogleService
                                        completionHandler:^(LMAddress *address, NSError *error) {
                                            if (address && !error) {
                                                NSLog(@"Address: %@", address.formattedAddress);
                                                self.addressTextField.text = address.formattedAddress;
                                            }
                                            else {
                                                NSLog(@"Error: %@", error.description);
                                            }
                                        }];
}

- (IBAction)onGetCoordinates:(id)sender {
    [[LMGeocoder sharedInstance] geocodeAddressString:self.addressTextField.text
                                              service:kLMGeocoderGoogleService
                                    completionHandler:^(LMAddress *address, NSError *error) {
                                        if (address && !error) {
                                            NSLog(@"Moving to address: %@, with coordinate: (%f, %f)", self.addressTextField.text, address.coordinate.latitude, address.coordinate.longitude);
                                            [self moveToCoordinates:address.coordinate withVisibleDistance:800];
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
