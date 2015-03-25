//
//  OrdersViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrdersViewController.h"
#import "TKOrderSummaryCell.h"
#import "ParseAPI.h"
#import "ReviewViewController.h"
#import "OrderStatusViewController.h"
#import "DayCell.h"
#import "TKHeader.h"

@interface OrdersViewController () <UITableViewDataSource, UITableViewDelegate, OrderStatusViewControllerDelegate>

@property (weak, nonatomic) IBOutlet TKHeader *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DayCell *sizingCell;

@property (strong, nonatomic) NSArray *orders;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *backButton = [[UIButton alloc] initWithFrame:self.headerView.leftView.bounds];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    backButton.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    [self.headerView.leftView addSubview:backButton];

    self.title = @"Orders";
    self.orders = [[ParseAPI getInstance] ordersForUser:[PFUser currentUser]];

    // Sort orders by date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deliveryDateAndTime" ascending:NO];
    self.orders = [self.orders sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DayCell" bundle:nil] forCellReuseIdentifier:@"DayCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    [self.tableView reloadData];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayCell" forIndexPath:indexPath];
    Order *order = self.orders[indexPath.row];
    NSDictionary *shortNameToMenuOptionObject = order.shortNameToMenuOptionObject;
    MenuOption *menuOption = [shortNameToMenuOptionObject objectForKey:[shortNameToMenuOptionObject allKeys][0]];
    [cell setDate:order.deliveryDateAndTime andMenuOption:menuOption];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ReviewViewController *rvc = [[ReviewViewController alloc] init];
    OrderStatusViewController *osvc = [[OrderStatusViewController alloc] init];
    osvc.delegate = self;
    osvc.order = self.orders[indexPath.row];
    [self presentViewController:osvc animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Initialize the sizing cell
    if (!self.sizingCell) {
        self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"DayCell"];
    }

    // Populate cell with the same data as the visible cell
    Order *order = self.orders[indexPath.row];
    NSDictionary *shortNameToMenuOptionObject = order.shortNameToMenuOptionObject;
    MenuOption *menuOption = [shortNameToMenuOptionObject objectForKey:[shortNameToMenuOptionObject allKeys][0]];
    [self.sizingCell setDate:order.deliveryDateAndTime andMenuOption:menuOption];
    
    [self.sizingCell setNeedsUpdateConstraints];
    [self.sizingCell updateConstraintsIfNeeded];
    
    // Set cell width to the same width as tableView
    self.sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.sizingCell.bounds));
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
    
    // Get the height of the sizing cell, adding one to compensate for cell separators
    CGFloat height = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
    NSLog(@"Calculated height %f for row %lu", height, (unsigned long)indexPath.row);
    return height;
}

#pragma mark - Button Actions

- (void)onBackButton {
    [self.delegate ordersViewControllerShouldBeDismissed:self];
}

#pragma mark - OrderStatusViewControllerDelegate methods

- (void)orderStatusViewControllerShouldBeDismissed:(OrderStatusViewController *)orderStatusViewController {
    [orderStatusViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
