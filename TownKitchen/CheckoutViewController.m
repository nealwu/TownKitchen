//
//  CheckoutViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutViewController.h"

#import "CheckoutOrderItemCell.h"
#import "MenuOption.h"
#import "AddressInputViewController.h"
#import <GoogleKit.h>
#import "LocationSelectViewController.h"
#import "TimeSelectViewController.h"
#import "OrdersViewController.h"
#import "ParseAPI.h"

@interface CheckoutViewController () <UITableViewDataSource, UITableViewDelegate, LocationSelectViewControllerDelegate, TimeSelectViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) NSArray *orderItems;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSDate *selectedDate;

@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom setters

- (void)setOrder:(Order *)order {
    _order = order;
    [self reloadTableData];
    
    // populate menu option shortnames and retrieve corresponding objects
    NSMutableArray *mutableMenuOptionShortnames = [NSMutableArray array];
    NSMutableDictionary *mutableShortNameToObject = [NSMutableDictionary dictionary];
    
    for (NSString *shortName in order.items) {
        if ([order.items[shortName] isEqualToNumber:@0]) {
            continue;
        }
        else {
            [mutableMenuOptionShortnames addObject:shortName];
            [mutableShortNameToObject addEntriesFromDictionary:@{ shortName : [[ParseAPI getInstance] menuOptionForShortName:shortName] }];
            self.menuOptionShortNames = [NSArray arrayWithArray:mutableMenuOptionShortnames];
            self.shortNameToObject = [NSDictionary dictionaryWithDictionary:mutableShortNameToObject];
            [self reloadTableData];
        }
    }
}

#pragma mark Private Methods

- (void)setup{
    // tableView methods
    self.title = @"Checkout";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckoutOrderItemCell" bundle:nil] forCellReuseIdentifier:@"CheckoutOrderItemCell"];
    [self reloadTableData];
    
}

- (void)reloadTableData {
    [self.tableView reloadData];
}

- (void)setAddress {
    LocationSelectViewController *lvc = [[LocationSelectViewController alloc] init];
    lvc.delegate = self;
    [self presentViewController:lvc animated:YES completion:nil];
}

- (void)setTime {
    TimeSelectViewController *tvc = [[TimeSelectViewController alloc] init];
    tvc.delegate = self;
    [self presentViewController:tvc animated:YES completion:nil];
    if (self.selectedDate) {
        [tvc.datePicker setDate:self.selectedDate animated:NO];
    }
}

#pragma mark LocationSelectViewControllerDelegate methods

- (void)locationSelectViewController:(LocationSelectViewController *)locationSelectViewController didSelectAddress:(NSString *)address {
    self.addressLabel.text = address;
    self.order.deliveryAddress = address;
}

#pragma mark LocationSelectViewControllerDelegate Methods

- (void)timeSelectViewController:(TimeSelectViewController *)tvc didSetTime:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:date];
    NSLog(@"got time from selector: %@", currentTime);
    self.timeLabel.text = currentTime;
    self.selectedDate = date;

    // Extract only the time portion of the date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:NSUIntegerMax fromDate:self.order.deliveryDateAndTime];
    NSDateComponents *timeComponents = [calendar components:NSUIntegerMax fromDate:date];
    [dayComponents setHour:timeComponents.hour];
    [dayComponents setMinute:timeComponents.minute];
    [dayComponents setSecond:timeComponents.second];
    self.order.deliveryDateAndTime = [calendar dateFromComponents:dayComponents];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuOptionShortNames.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckoutOrderItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckoutOrderItemCell"];

    if (indexPath.row < self.menuOptionShortNames.count) {
        NSString *shortName = self.menuOptionShortNames[indexPath.row];
        MenuOption *menuOption = self.shortNameToObject[shortName];
        float menuOptionPrice = [menuOption.price floatValue];
        float quantity = [self.order.items[shortName] floatValue];
        float priceForQuantity = menuOptionPrice * quantity;
        cell.quantity = [NSNumber numberWithFloat:quantity];
        cell.price = [NSNumber numberWithFloat:priceForQuantity];
        cell.itemDescription = menuOption.mealDescription;
    } else {
        cell.itemDescription = @"Total";
        cell.price = self.order.totalPrice;
        cell.quantity = @0;
    }

    return cell;
}

#pragma mark Actions

- (IBAction)onPlaceOrder:(id)sender {
    self.order.user = [PFUser currentUser];
    self.order.status = @"paid";
    self.order.driverLocation = [PFGeoPoint geoPointWithLatitude:37.4 longitude:-122.1];

    NSLog(@"validating order: %@", self.order);
    NSLog(@"result: %hhd", (char)[[ParseAPI getInstance] validateOrder:self.order]);

    if ([[ParseAPI getInstance] validateOrder:self.order]) {
        [[ParseAPI getInstance] createOrder:self.order];
    }

    OrdersViewController *ovc = [[OrdersViewController alloc] init];
    [self presentViewController:ovc animated:YES completion:nil];
}

- (IBAction)onSetAddressButton:(id)sender {
    [self setAddress];
}

- (IBAction)onSetTimeButton:(id)sender {
    [self setTime];
}

@end
