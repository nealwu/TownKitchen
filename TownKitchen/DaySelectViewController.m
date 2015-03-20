//
//  DaySelectViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectViewController.h"
#import "DayCell.h"
#import "ParseAPI.h"
#import "Inventory.h"
#import "UIImageView+AFNetworking.h"
#import "OrderCreationViewController.h"
#import "DateUtils.h"
#import "DaySelectAnimationController.h"
#import "OrdersViewController.h"
#import "DeliveryStatusViewController.h"
#import "TKHeader.h"
#import "LoginViewController.h"

@interface DaySelectViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, DeliveryStatusViewControllerDelegate, LoginViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *inventoryItems;
@property (strong, nonatomic) NSArray *displayInventories;

@property (strong, nonatomic) DayCell *sizingCell;
@property (strong, nonatomic) DaySelectAnimationController *daySelectAnimationController;
@property (weak, nonatomic) IBOutlet TKHeader *header;

@end

@implementation DaySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.inventoryItems = [[ParseAPI getInstance] inventoryItems];

    NSMutableArray *uniqueInventories = [NSMutableArray array];
    NSMutableSet *dates = [NSMutableSet set];

    for (Inventory *inventory in self.inventoryItems) {
        NSString *monthAndDay = [DateUtils monthAndDayFromDate:inventory.dateOffered];

        if (![dates containsObject:monthAndDay]) {
            [uniqueInventories addObject:inventory];
            [dates addObject:monthAndDay];
        }
    }

    // Sort uniqueInventories by date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateOffered" ascending:YES];
    self.displayInventories = [uniqueInventories sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    // Table view methods
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DayCell" bundle:nil] forCellReuseIdentifier:@"DayCell"];

    // Set up header
    UIImageView *TKLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-logo"]];
    [self.header.titleView addSubview:TKLogoImageView];
    [self setupButtons];
    
    // Initialize animation controller
    self.daySelectAnimationController = [DaySelectAnimationController new];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"current user = %@", [PFUser currentUser]);
    if (![PFUser currentUser]) {
        [self onLogoutButton];
    }
}

- (void)setupButtons {
    NSString *buttonTitle;
    SEL action;
    if ([[[PFUser currentUser] valueForKey:@"isDriver"] boolValue]) {
        buttonTitle = @"Deliver";
        action = @selector(onDeliveriesButton);
    } else {
        buttonTitle = @"Orders";
        action = @selector(onOrdersButton);
    }
    
    UIButton *ordersButton = [[UIButton alloc] initWithFrame:self.header.rightView.bounds];
    [ordersButton setTitle:buttonTitle forState:UIControlStateNormal];
    [ordersButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    ordersButton.autoresizingMask =
          UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin;
    [self.header.rightView addSubview:ordersButton];

    UIButton *logoutButton = [[UIButton alloc] initWithFrame:self.header.leftView.bounds];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(onLogoutButton) forControlEvents:UIControlEventTouchUpInside];
    logoutButton.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    [self.header.leftView addSubview:logoutButton];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayInventories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Inventory *inventory = self.displayInventories[indexPath.row];

    DayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayCell" forIndexPath:indexPath];
    [cell setDate:inventory.dateOffered andMenuOption:inventory.menuOptionObject];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OrderCreationViewController *ocvc = [[OrderCreationViewController alloc] init];
    Inventory *firstInventory = self.displayInventories[indexPath.row];
    ocvc.inventoryItems = [self filterInventoryItemsByDay:firstInventory.dateOffered];
    ocvc.transitioningDelegate = self;
    
    // Prepare the animation
    self.daySelectAnimationController.selectedCell = (DayCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.daySelectAnimationController.contentOffset = self.tableView.contentOffset;
    
    [self presentViewController:ocvc animated:YES completion:^{
        nil;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Initialize the sizing cell
    if (!self.sizingCell) {
        self.sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"DayCell"];
    }
    
    // Populate cell with the same data as the visible cell
    Inventory *inventory = self.displayInventories[indexPath.row];
    [self.sizingCell setDate:inventory.dateOffered andMenuOption:inventory.menuOptionObject];
    
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

#pragma mark - Button Actions

- (void)onOrdersButton {
    OrdersViewController *ovc = [[OrdersViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ovc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onDeliveriesButton {
    DeliveryStatusViewController *dsvc = [[DeliveryStatusViewController alloc] init];
    dsvc.delegate = self;
    [self presentViewController:dsvc animated:YES completion:nil];
}

- (void)onLogoutButton {
    [PFUser logOut];
    LoginViewController *lvc = [[LoginViewController alloc] init];
    lvc.delegate = self;
    [self presentViewController:lvc animated:YES completion:nil];
}

#pragma mark - LoginViewControllerDelegate Methods

- (void)loginViewController:(LoginViewController *)loginViewController didLoginUser:(PFUser *)user {
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DeliveryStatusViewControllerDelegate Methods

- (void)deliveryStatusViewControllerShouldBeDismissed:(DeliveryStatusViewController *)deliveryStatusViewController {
    [deliveryStatusViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.daySelectAnimationController.animationType = AnimationTypePresent;
    return self.daySelectAnimationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.daySelectAnimationController.animationType = AnimationTypeDismiss;
    return self.daySelectAnimationController;
}

#pragma mark - Private methods

- (NSArray *)filterInventoryItemsByDay:(NSDate *)date {
    NSMutableArray *filteredItems = [NSMutableArray array];

    for (Inventory *inventory in self.inventoryItems) {
        if ([DateUtils compareDayFromDate:inventory.dateOffered withDate:date]) {
            [filteredItems addObject:inventory];
        }
    }

    return filteredItems;
}

@end
