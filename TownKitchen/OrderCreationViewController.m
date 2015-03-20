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
#import "CheckoutAnimationController.h"
#import "CheckoutView.h"
#import <UIView+MTAnimation.h>
#import "PaymentView.h"

@interface OrderCreationViewController () <UITableViewDelegate, UITableViewDataSource, OrderCreationTableViewCellDelegate, UIViewControllerTransitioningDelegate, CheckoutViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TKHeader *header;

@property (strong, nonatomic) OrderCreationCell *sizingCell;
@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (strong, nonatomic) NSMutableDictionary *shortNameToQuantity;
@property (strong, nonatomic) CheckoutAnimationController *checkoutAnimationController;
@property (strong, nonatomic) DateLabelsViewSmall *dateLabelsViewSmall;
@property (strong, nonatomic) CheckoutView *checkoutView;
@property (strong, nonatomic) PaymentView *paymentView;

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
    self.dateLabelsViewSmall = [[DateLabelsViewSmall alloc] initWithFrame:self.header.titleView.bounds];
    self.dateLabelsViewSmall.weekdayLabel.text = [DateUtils dayOfTheWeekFromDate:firstInventory.dateOffered];
    self.dateLabelsViewSmall.monthAndDayLabel.text = [DateUtils monthAndDayFromDate:firstInventory.dateOffered];
    [self.header.titleView addSubview:self.dateLabelsViewSmall];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:self.header.leftView.bounds];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.header.leftView addSubview:backButton];
    
    // Initialize animation controller
    self.checkoutAnimationController = [[CheckoutAnimationController alloc] init];
}

- (void)viewWillLayoutSubviews {
    
}

#pragma mark - OrderCreationTableViewCellDelegate Methods

- (void)orderCreationTableViewCell:(OrderCreationCell *)cell didUpdateQuantity:(NSNumber *)quantity {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    if (quantity.integerValue == 0) {
        [self.shortNameToQuantity removeObjectForKey:shortName];
    } else {
        self.shortNameToQuantity[shortName] = quantity;
    }
    NSLog(@"updated quantity for %@, quantities dictionary is now: %@", shortName, self.shortNameToQuantity);
}

#pragma mark - CheckoutViewDelegate Methods

- (void)paymentButtonPressedFromCheckoutView:(CheckoutView *)view {
    NSLog(@"ocvc heard payment button pressed");

    // initialize paymentView
    self.paymentView = [[PaymentView alloc] init];
    
    // define frame variables
    CGFloat parentWidth = self.view.bounds.size.width;
    CGFloat parentHeight = self.view.bounds.size.height;
    CGFloat horizontalGapSize = 20.0;
    CGFloat navigationBarHeight = 64;
    
    // define initial and final frames, set initial
    CGRect finalFrame = CGRectMake(horizontalGapSize / 2, navigationBarHeight + horizontalGapSize / 2, parentWidth - horizontalGapSize, parentHeight - horizontalGapSize / 2 - navigationBarHeight);
    CGRect initialFrame = finalFrame;
    initialFrame.origin.x += initialFrame.size.width;
    self.paymentView.frame = initialFrame;
    
    // set paymentView shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.checkoutView.bounds];
    self.paymentView.layer.masksToBounds = NO;
    self.paymentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.paymentView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.paymentView.layer.shadowOpacity = 0.5f;
    self.paymentView.layer.shadowPath = shadowPath.CGPath;

    [self.view addSubview:self.paymentView];
    
    // animate transition
    [UIView mt_animateWithViews:@[self.paymentView]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         self.paymentView.frame = finalFrame;
                     } completion:^{
                         nil;
                     }];
}

- (void)orderButtonPressedFromCheckoutView:(CheckoutView *)view {
    NSLog(@"ocvc heard order button pressed");
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

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.checkoutAnimationController.animationType = AnimationTypePresent;
    self.checkoutAnimationController.dateLabelsViewSmall = self.dateLabelsViewSmall;
    return self.checkoutAnimationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.checkoutAnimationController.animationType = AnimationTypeDismiss;
    return nil;
    return self.checkoutAnimationController;
}

#pragma mark Private methods

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
    
    // initialize checkoutView
    self.checkoutView = [[CheckoutView alloc] init];
    self.checkoutView.shortNameToObject = self.shortNameToObject;
    self.checkoutView.menuOptionShortNames = self.menuOptionShortNames;
    self.checkoutView.order = order;
    self.checkoutView.buttonState = ButtonStateEnterPayment;
    self.checkoutView.delegate = self;
    
    // set checkoutView frame
    CGFloat parentWidth = self.view.bounds.size.width;
    CGFloat parentHeight = self.view.bounds.size.height;
    CGFloat horizontalGapSize = 20.0;
    CGFloat navigationBarHeight = 64;
    
    // define initial and final frames, set initial
    CGRect finalFrame = CGRectMake(horizontalGapSize / 2, navigationBarHeight + horizontalGapSize / 2, parentWidth - horizontalGapSize, parentHeight - horizontalGapSize / 2 - navigationBarHeight);
    CGRect initialFrame = finalFrame;
    initialFrame.origin.y += initialFrame.size.height;
    self.checkoutView.frame = initialFrame;
    
    // set checkoutView shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.checkoutView.bounds];
    self.checkoutView.layer.masksToBounds = NO;
    self.checkoutView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.checkoutView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.checkoutView.layer.shadowOpacity = 0.5f;
    self.checkoutView.layer.shadowPath = shadowPath.CGPath;
    
    // create gray filter view
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, parentWidth, parentHeight - navigationBarHeight)];
    filterView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:0.75];
    filterView.alpha = 0.0;
    
    [self.view addSubview:filterView];
    [self.view addSubview:self.checkoutView];

    // animate transition
    [UIView mt_animateWithViews:@[self.checkoutView]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         self.checkoutView.frame = finalFrame;
                     } completion:^{
                         nil;
                     }];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         filterView.alpha = 1.0;
                     } completion:nil];
}

- (IBAction)onBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end