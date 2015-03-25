//
//  DeliveryStatusViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Bolts.h>
#import "DeliveryStatusViewController.h"
#import "OrderStatusViewController.h"
#import "ParseAPI.h"
#import "TKHeader.h"
#import "TKOrderSummaryCell.h"

static const NSTimeInterval kUpdateInterval = 5.0;

@interface DeliveryStatusViewController () <UITableViewDataSource, UITableViewDelegate, OrderStatusViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet TKHeader *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TKOrderSummaryCell *sizingCell;

@property (strong, nonatomic) NSArray *orders;
@property (strong, nonatomic) Order *activeOrder;
@property (weak, nonatomic) TKOrderSummaryCell *activeOrderCell;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSTimeInterval timeOfLastUpdate;

@end

@implementation DeliveryStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:self.headerView.leftView.bounds];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:@"Futura" size:17];
    [doneButton addTarget:self action:@selector(onDoneButton) forControlEvents:UIControlEventTouchUpInside];
    doneButton.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin;
    [self.headerView.leftView addSubview:doneButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.headerView.titleView.bounds];
    titleLabel.text = @"Deliveries";
    titleLabel.font = [UIFont fontWithName:@"Futura" size:24];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin;

    [self.headerView.titleView addSubview:titleLabel];
    
    UINib *cellNib = [UINib nibWithNibName:@"TKOrderSummaryCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"TKOrderSummaryCell"];
    
    self.sizingCell = [cellNib instantiateWithOwner:nil options:nil].firstObject;
    
    BFTask *ordersTask = [[ParseAPI getInstance] ordersForToday];
    [ordersTask continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error while fetching ordersForToday: %@", task.error);
        } else {
            self.orders = task.result;
            NSLog(@"Calling reloadData");
            [self.tableView reloadData];
        }
        return nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (void)onDoneButton {
    self.activeOrderCell.isTrackingForDelivery = NO;
    [self.locationManager stopUpdatingLocation];
    [self.delegate deliveryStatusViewControllerShouldBeDismissed:self];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TKOrderSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TKOrderSummaryCell"];
    cell.order = self.orders[indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sizingCell.order = self.orders[indexPath.row];
    [self.sizingCell layoutIfNeeded];
    CGFloat height = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    NSLog(@"calculated height %f for cell at row %ld", height, (long) indexPath.row);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    OrderStatusViewController *osvc = [[OrderStatusViewController alloc] init];
//    osvc.delegate = self;
//    osvc.order = self.orders[indexPath.row];
//    osvc.reportLocationAsDriverLocation = YES;
//    [self presentViewController:osvc animated:YES completion:nil];
    self.activeOrderCell.isTrackingForDelivery = NO;
    self.activeOrder = self.orders[indexPath.row];
    TKOrderSummaryCell *cell = (TKOrderSummaryCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.isTrackingForDelivery = YES;
    self.activeOrderCell = cell;
    
    [self startTrackingOrder];
}

#pragma mark OrderStatusViewControllerDelegate

- (void)orderStatusViewControllerShouldBeDismissed:(OrderStatusViewController *)orderStatusViewController {
    [orderStatusViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delivery Tracking

- (void)startTrackingOrder {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
    }
    [self.locationManager startUpdatingLocation];


    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.activeOrder.deliveryAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error during geocodeAddressString: %@", error);
        } else {
            MKPlacemark *firstMatch = placemarks[0];
            NSLog(@"geocodeAddressString first match: %@ @ %@", firstMatch.name, firstMatch.location);
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:firstMatch];
            [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
        }
    }];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /* keep network activity low by only updating occassionally */
    if (self.timeOfLastUpdate < CACurrentMediaTime() - kUpdateInterval) {
        NSLog(@"Update location of %@ to %@", self.activeOrder, locations.lastObject);
        [[ParseAPI getInstance] updateOrder:self.activeOrder withDriverLocation:locations.lastObject];
        self.timeOfLastUpdate = CACurrentMediaTime();
    }
}

@end
