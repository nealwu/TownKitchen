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
#import "DeliveryButton.h"
#import "OrdersViewController.h"
#import "OrderStatusViewController.h"
#import "ProfileViewController.h"
#import "DeliveryStatusViewController.h"
#import "TKHeader.h"
#import "LoginViewController.h"
#import "ReviewViewController.h"

@interface DaySelectViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, DeliveryStatusViewControllerDelegate, LoginViewControllerDelegate, OrderStatusViewControllerDelegate, ProfileViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DeliveryButton *deliveryButton;
@property (assign, nonatomic) BOOL didAnimateActiveDeliveryButtonOnFirstLoad;
@property (strong, nonatomic) NSArray *inventoryItems;
@property (strong, nonatomic) NSArray *displayInventories;

@property (strong, nonatomic) DayCell *sizingCell;
@property (strong, nonatomic) DaySelectAnimationController *daySelectAnimationController;
@property (weak, nonatomic) IBOutlet TKHeader *header;

@property (strong, nonatomic) Order *activeOrder;

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
    
    // Initialize animation controller
    self.daySelectAnimationController = [DaySelectAnimationController new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidReceiveNotification:) name:@"TKDidReceiveNotification" object:nil];
    
    [self setupButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    // When loading view for first time, animate the button
    if (!self.didAnimateActiveDeliveryButtonOnFirstLoad) {
        [self checkForActiveDeliveryAnimated:YES];
        
    } else {
        [self checkForActiveDeliveryAnimated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"current user = %@", [PFUser currentUser]);
    
    if (![PFUser currentUser]) {
        [self onLogoutButton];
    } else {
        NSArray *orders = [[ParseAPI getInstance] ordersForUser:[PFUser currentUser]];
        NSDate *now = [NSDate date];
        
        for (Order *order in orders) {
            if ([order.status isEqualToString:@"delivered"]) {
                double minuteTimeDifference = [now timeIntervalSinceDate:order.deliveryDateAndTime] / 60.0;
                NSLog(@"Time difference: %lf minutes", minuteTimeDifference);
                
                // Present the ReviewViewController if the order was delivered at least 30 minutes ago and at most 3 days ago
                if (minuteTimeDifference > 30 && minuteTimeDifference < 3 * 24 * 60) {
                    NSLog(@"Presenting ReviewViewController");
                    ReviewViewController *rvc = [[ReviewViewController alloc] init];
                    rvc.order = order;
                    [self presentViewController:rvc animated:YES completion:nil];
                }
            }
        }
    }
}

- (void)onDidReceiveNotification:(NSNotification *)notification {
    NSLog(@"DaySelectViewController received notification: %@", notification);
    [self checkForActiveDeliveryAnimated:YES];
}

- (void)checkForActiveDelivery {
    [self checkForActiveDeliveryAnimated:NO];
}

- (void)checkForActiveDeliveryAnimated:(BOOL)animated {
    self.activeOrder = [[ParseAPI getInstance] orderBeingDeliveredForUser:[PFUser currentUser]];
    
    if (self.activeOrder && animated) {
        if (!self.didAnimateActiveDeliveryButtonOnFirstLoad) {
            // when loading view for first time, start the animation after a delay
            self.didAnimateActiveDeliveryButtonOnFirstLoad = YES;
            [self animateDeliveryButtonEnabledWithDelay];
            
        } else {
            [self animateDeliveryButtonEnabled];
        }
        
    } else if (self.activeOrder) {
        self.deliveryButton.active = YES;
        
    } else {
        self.deliveryButton.active = NO;
    }
}

- (void)setupButtons {
    NSLog(@"setup buttons");
    UIButton *deliveriesButton = [[UIButton alloc] initWithFrame:self.header.rightView.bounds];
    [deliveriesButton setImage:[UIImage imageNamed:@"car-button"] forState:UIControlStateNormal];
    [deliveriesButton addTarget:self action:@selector(onDeliveriesButton) forControlEvents:UIControlEventTouchUpInside];
    
    // Create profile button
    CGRect profileButtonFrame = self.header.leftView.bounds;
    UIButton *profileButton = [[UIButton alloc] initWithFrame:profileButtonFrame];
    [profileButton addTarget:self action:@selector(onProfileButton) forControlEvents:UIControlEventTouchUpInside];
    [profileButton setImage:[UIImage imageNamed:@"user-profile-button"] forState:UIControlStateNormal];
    [profileButton setImage:[UIImage imageNamed:@"user-profile-button-highlighted"] forState:UIControlStateHighlighted];
    [self.header.leftView.subviews.firstObject removeFromSuperview];
    [self.header.leftView addSubview:profileButton];
    
    // Create active delivery button
    CGRect activeDeliveryButtonFrame = self.header.rightView.bounds;
    if (!self.deliveryButton) {
        self.deliveryButton = [[DeliveryButton alloc] initWithFrame:activeDeliveryButtonFrame];
        [self.deliveryButton addTarget:self action:@selector(onActiveOrderButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.header.rightView.subviews.firstObject removeFromSuperview];
    if ([[[PFUser currentUser] valueForKey:@"isDriver"] boolValue]) {
        [self.header.rightView addSubview:deliveriesButton];
    } else {
        [self.header.rightView addSubview:self.deliveryButton];
    }
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
    
    [self presentViewController:ocvc animated:YES completion:nil];
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

- (void)onProfileButton {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.delegate = self;
    [self presentViewController:profileViewController animated:YES completion:nil];
}

- (void)onLogoutButton {
    [PFUser logOut];
    LoginViewController *lvc = [[LoginViewController alloc] init];
    lvc.delegate = self;
    [self presentViewController:lvc animated:YES completion:nil];
}

- (void)onActiveOrderButton {
    OrderStatusViewController *osvc = [[OrderStatusViewController alloc] init];
    osvc.delegate = self;
    osvc.order = self.activeOrder;
    [self presentViewController:osvc animated:YES completion:nil];
}

#pragma mark - LoginViewControllerDelegate Methods

- (void)loginViewController:(LoginViewController *)loginViewController didLoginUser:(PFUser *)user {
    [loginViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ProfileViewControllerDelegate Methods

- (void)profileViewControllerDidLogout:(ProfileViewController *)pvc {
    [self onLogoutButton];
}

#pragma mark - DeliveryStatusViewControllerDelegate Methods

- (void)deliveryStatusViewControllerShouldBeDismissed:(DeliveryStatusViewController *)deliveryStatusViewController {
    [deliveryStatusViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OrderStatusViewControllerDelegate Methods

- (void)orderStatusViewControllerShouldBeDismissed:(OrderStatusViewController *)orderStatusViewController {
    [orderStatusViewController dismissViewControllerAnimated:YES completion:nil];
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

- (void)animateDeliveryButtonEnabled {
    [self.deliveryButton setButtonState:ButtonStateActive animated:YES];
}

- (void)animateDeliveryButtonEnabledWithDelay {
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(animateDeliveryButtonEnabled) userInfo:nil repeats:NO];
}

@end
