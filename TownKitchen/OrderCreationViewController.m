//
//  OrderCreationViewController.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCreationViewController.h"

#import "CheckoutViewController.h"
#import "DateUtils.h"
#import "Inventory.h"
#import "LocationSelectViewController.h"
#import "Order.h"
#import "OrderCreationCell.h"
#import "TKHeader.h"
#import "DateLabelsViewSmall.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource, OrderCreationTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) OrderCreationCell *sizingCell;
@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (strong, nonatomic) NSMutableDictionary *shortNameToQuantity;
@property (weak, nonatomic) IBOutlet TKHeader *header;

@end

@implementation OrderCreationViewController

#pragma mark - View Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    Inventory *firstInventory = self.inventoryItems[0];
    self.title = [DateUtils monthAndDayFromDate:firstInventory.dateOffered];

    // retrieve MenuOption objects
    NSMutableArray *mutableMenuOptionShortNames = [NSMutableArray array];
    NSMutableDictionary *mutableShortNameToObject = [NSMutableDictionary dictionary];
    self.shortNameToQuantity = [NSMutableDictionary dictionary];

    for (Inventory *inventoryItem in self.inventoryItems) {
        NSString *shortName = inventoryItem.menuOptionShortName;

        [mutableMenuOptionShortNames addObject:shortName];
        [self.shortNameToQuantity setObject:@0 forKey:shortName];

        MenuOption *menuOption = inventoryItem.menuOptionObject;
        [mutableShortNameToObject setObject:menuOption forKey:shortName];

        self.menuOptionShortNames = [NSArray arrayWithArray:mutableMenuOptionShortNames];
        self.shortNameToObject = [NSDictionary dictionaryWithDictionary:mutableShortNameToObject];
    }

    // Set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCreationCell" bundle:nil] forCellReuseIdentifier:@"OrderCreationCell"];
    [self.tableView reloadData];
    
    // set up header
    DateLabelsViewSmall *dateLabelsViewSmall = [[DateLabelsViewSmall alloc] initWithFrame:self.header.titleView.bounds];
    dateLabelsViewSmall.weekdayLabel.text = [DateUtils dayOfTheWeekFromDate:firstInventory.dateOffered];
    dateLabelsViewSmall.monthAndDayLabel.text = [DateUtils monthAndDayFromDate:firstInventory.dateOffered];
    [self.header.titleView addSubview:dateLabelsViewSmall];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:self.header.leftView.bounds];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.header.leftView addSubview:backButton];
}

#pragma mark - OrderCreationTableViewCellDelegate Methods

- (void)orderCreationTableViewCell:(OrderCreationCell *)cell didUpdateQuantity:(NSNumber *)quantity {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    self.shortNameToQuantity[shortName] = quantity;
    NSLog(@"updated quantity for %@, quantities dictionary is now: %@", shortName, self.shortNameToQuantity);
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuOptionShortNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCreationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationCell"];
    cell.delegate = self;

    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    cell.menuOption = self.shortNameToObject[shortName];
    cell.quantity = self.shortNameToQuantity[shortName];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Initialize the sizing cell
    if (!self.sizingCell) {
        self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderCreationCell"];
    }

    // Populate cell with the same data as the visible cell
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    self.sizingCell.menuOption = self.shortNameToObject[shortName];
    self.sizingCell.quantity = self.shortNameToQuantity[shortName];
    
    [self.sizingCell setNeedsUpdateConstraints];
    [self.sizingCell updateConstraintsIfNeeded];

    // Set cell width to the same width as tableView
    self.sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.sizingCell.bounds));
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];

    // Get the height of the sizing cell, adding one to compensate for cell separators
    CGFloat height = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    return height;
}

#pragma mark - Actions

- (IBAction)onOrderButton:(id)sender {
    Order *order = [Order object];
    order.items = self.shortNameToQuantity;
    order.user = [PFUser currentUser];
    Inventory *firstInventory = self.inventoryItems[0];
    order.deliveryDateAndTime = [firstInventory dateOffered];
    order.shortNameToMenuOptionObject = self.shortNameToObject;

    order.totalPrice = @0;

    for (NSString *shortName in order.items) {
        MenuOption *menuOption = order.shortNameToMenuOptionObject[shortName];
        order.totalPrice = @([order.totalPrice doubleValue] + [menuOption.price doubleValue] * [order.items[shortName] doubleValue]);
    }

    NSLog(@"Creating order: %@", order);

    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
    checkoutViewController.order = order;
    
    [self presentViewController:checkoutViewController animated:YES completion:nil];
}
- (IBAction)onBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end