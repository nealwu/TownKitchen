//
//  CheckoutViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 4/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutViewController.h"

#import "CheckoutOrderItemCell.h"
#import "MenuOption.h"

#import "AppDelegate.h"
#import "LocationSelectViewController.h"
#import <MBProgressHUD.h>
#import "OrderConfirmationViewController.h"
#import "ParseAPI.h"
#import "PaymentViewController.h"
#import "PopupAnimationController.h"
#import "PopupDismissAnimationController.h"
#import "STPCard.h"
#import "STPAPIClient.h"
#import <UIView+MTAnimation.h>


@interface CheckoutViewController () <UITableViewDataSource, UITableViewDelegate, CheckoutOrderButtonDelegate, LocationSelectViewControllerDelegate, PaymentViewControllerDelegate, OrderConfirmationViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *addressAndTimeView;
@property (weak, nonatomic) IBOutlet UIImageView *addressButtonBackground;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UIImageView *timeButtonBackground;
@property (weak, nonatomic) IBOutlet UIPickerView *timePickerView;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (strong, nonatomic) NSArray *timeOptionTitles;
@property (strong, nonatomic) NSArray *timeOptionDateObjects;
@property (strong, nonatomic) NSDateFormatter *timePickerDateFormatter;

@property (strong, nonatomic) PaymentViewController *paymentViewController;
@property (strong, nonatomic) LocationSelectViewController *locationSelectViewController;
@property (strong, nonatomic) OrderConfirmationViewController *orderConfirmationViewController;

@property (assign, nonatomic) BOOL didSetTime;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIPushBehavior *timePickerPushBehavior;
@property (strong, nonatomic) UIPushBehavior *addressLabelPushBehavior;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

#pragma mark - Custom setters

- (void)setOrder:(Order *)order {
    _order = order;
    
    // remove menu option shortnames that have zero quantity
    NSMutableArray *mutableMenuOptionShortnames = [NSMutableArray array];
    for (NSString *shortName in order.items) {
        if ([order.items[shortName] isEqualToNumber:@0]) {
            continue;
        }
        else {
            [mutableMenuOptionShortnames addObject:shortName];
        }
    }
    self.menuOptionShortNames = [NSArray arrayWithArray:mutableMenuOptionShortnames];
    [self.tableView reloadData];
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%.2f", [self.order.totalPrice floatValue]];
}

- (void)setButtonState:(ButtonState)buttonState {
    _buttonState = buttonState;
    self.checkoutOrderButton.buttonState = buttonState;
}

- (void)setDidSetAddress:(BOOL)didSetAddress {
    _didSetAddress = didSetAddress;
    if (didSetAddress) {
        [self hideAddressButtonBackground];
    }
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuOptionShortNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckoutOrderItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckoutOrderItemCell"];
    
    NSString *shortName = self.menuOptionShortNames[indexPath.row];
    MenuOption *menuOption = self.shortNameToObject[shortName];
    float menuOptionPrice = [menuOption.price floatValue];
    float quantity = [self.order.items[shortName] floatValue];
    float priceForQuantity = menuOptionPrice * quantity;
    
    cell.quantity = [NSNumber numberWithFloat:quantity];
    cell.price = [NSNumber numberWithFloat:priceForQuantity];
    cell.itemDescription = menuOption.mealDescription;
    cell.imageUrl = menuOption.imageURL;
    
    return cell;
}

#pragma mark - LocationSelectViewControllerDelegate Methods

// user selected delivery address
- (void)locationSelectViewController:(LocationSelectViewController *)locationSelectViewController didSelectAddress:(NSString *)address withShortString:(NSString *)shortString {
    self.order.deliveryAddress = address;
    self.addressLabel.text = shortString;
    self.didSetAddress = YES;
    [self hideViewControllerAnimateToBottom:locationSelectViewController];
}

#pragma mark - PaymentViewControllerDelegate Methods

- (void)onSetPaymentButtonFromPaymentViewController:(PaymentViewController *)pvc withCardValidity:(BOOL)valid {
    NSLog(@"PaymentViewControllerDelegate method called");
    if (valid) {
        self.buttonState = ButtonStatePlaceOrder;
    } else {
        self.buttonState = ButtonStateEnterPayment;
    }
    [self hideViewControllerAnimateToRight:self.paymentViewController];
}

#pragma mark - CheckoutOrderButtonDelegate Methods

- (void)onCheckoutOrderButton:(CheckoutOrderButton *)button withButtonState:(ButtonState)buttonState {
    if (buttonState == ButtonStateEnterPayment) {
        [self displayViewControllerAnimatedFromRight:self.paymentViewController];
        
    } else if (buttonState == ButtonStatePlaceOrder) {
        if ([self validateInput]){
            [self placeOrder];
        }
    }
}

#pragma mark - OrderConfirmationViewControllerDelegate Methods

- (void)onDoneButtonTappedFromOrderConfirmationViewController:(OrderConfirmationViewController *)viewController {
    [self.orderConfirmationViewController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.timeOptionTitles.count;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.timeOptionTitles[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UILabel *)recycledLabel {
    UILabel *label = recycledLabel;
    if (!label) {
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
        label.textColor = [UIColor whiteColor];
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    // hide separators
    [[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
    [[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // select time
    NSLog(@"picker selected row %ld with title %@", (long)row, self.timeOptionTitles[row]);
    if (row == 0) {
        [pickerView selectRow:1 inComponent:0 animated:YES];
        [self pickerView:pickerView didSelectRow:1 inComponent:0];
    } else {
        NSDate *selectedDate = self.timeOptionDateObjects[row];
        
        // Extract only the time portion of the date
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dayComponents = [calendar components:NSUIntegerMax fromDate:self.order.deliveryDateAndTime];
        NSDateComponents *timeComponents = [calendar components:NSUIntegerMax fromDate:selectedDate];
        [dayComponents setHour:timeComponents.hour];
        [dayComponents setMinute:timeComponents.minute];
        [dayComponents setSecond:timeComponents.second];
        self.order.deliveryDateAndTime = [calendar dateFromComponents:dayComponents];
        
        self.didSetTime = YES;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    if (presented == self.orderConfirmationViewController) {
        return [PopupAnimationController new];
    } else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if (dismissed == self.orderConfirmationViewController) {
        return [PopupDismissAnimationController new];
    } else {
        return nil;
    }
}

#pragma mark - Actions

- (IBAction)onAddressButton:(UIButton *)sender {
    [self displayViewControllerAnimatedFromBottom:self.locationSelectViewController];
    [self unDimAddressLabel];
}

- (IBAction)onAddressButtonTouchDown:(UIButton *)sender {
    [self dimAddressLabel];
}

- (IBAction)onAddressButtonTouchDragOutside:(UIButton *)sender {
    [self unDimAddressLabel];
}

- (IBAction)onTimeButton:(UIButton *)sender {
    self.timeButton.hidden = YES;
    [self unDimTimeLabel];
    [self hideTimeButtonBackground];
    [self.timePickerView selectRow:2 inComponent:0 animated:YES];
    [self pickerView:self.timePickerView didSelectRow:2 inComponent:0];
}

- (IBAction)onTimeButtonTouchDown:(UIButton *)sender {
    [self dimTimeLabel];
}

- (IBAction)onTimeButtonTouchDragOutside:(UIButton *)sender {
    [self unDimTimeLabel];
}

#pragma mark - Private Methods

- (void)placeOrder {
    NSLog(@"attempting to place order: %@", self.order);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);  // slight delay to let UI draw HUD
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.order.user = [PFUser currentUser];
        
        STPCard *card = [[STPCard alloc] init];
        PTKView *paymentEntryView = self.paymentViewController.paymentEntryView;
        
        card.number = paymentEntryView.card.number;
        card.expMonth = paymentEntryView.card.expMonth;
        card.expYear = paymentEntryView.card.expYear;
        card.cvc = paymentEntryView.card.cvc;
        NSLog(@"Set up card: %@", card);
        NSLog(@"%@ %ld %ld %@", paymentEntryView.card.number, (long) paymentEntryView.card.expMonth, (long) paymentEntryView.card.expYear, paymentEntryView.card.cvc);
        
        [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
            if (error) {
                NSLog(@"Error while handling card: %@", error);
            } else {
                [self createBackendChargeWithToken:token completion:nil];
            }
        }];
        
        NSLog(@"validating order: %@", self.order);
        NSLog(@"result: %hhd", (char)[[ParseAPI getInstance] validateOrder:self.order]);
        
        if ([[ParseAPI getInstance] validateOrder:self.order]) {
            self.order.status = @"paid";
            self.order.driverLocation = [PFGeoPoint geoPointWithLatitude:37.4 longitude:-122.1];
            [[ParseAPI getInstance] createOrder:self.order];
            
            self.orderConfirmationViewController = [[OrderConfirmationViewController alloc] init];
            self.orderConfirmationViewController.delegate = self;
            self.orderConfirmationViewController.email = [[PFUser currentUser] email];
            self.orderConfirmationViewController.transitioningDelegate = self;
            self.orderConfirmationViewController.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:self.orderConfirmationViewController animated:YES completion:nil];
            
            [[ParseAPI getInstance] sendEmailConfirmationForOrder:self.order];
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate registerForNotifications];
        } else {
            NSLog(@"Order failed");
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(void (^)(NSError *))completion {
    NSLog(@"Got the token: %@", token);
    //    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    //    request.HTTPMethod = @"POST";
    //    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    //    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    //
    //    [NSURLConnection sendAsynchronousRequest:request
    //                                       queue:[NSOperationQueue mainQueue]
    //                           completionHandler:^(NSURLResponse *response,
    //                                               NSData *data,
    //                                               NSError *error) {
    //                               if (completion != nil) {
    //                                   completion(error);
    //                               }
    //                           }];
}

- (BOOL)validateInput {
    
    if (self.didSetTime && self.didSetAddress) {
        return YES;
    }
    else if (!self.didSetAddress) {
        [self bounceAddressLabel];
    }
    else if (!self.didSetTime) {
        [self bounceTimePicker];
    }
    return NO;
}

- (void)bounceTimePicker {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.addressAndTimeView];
    
    CGFloat pickerViewHeight = self.timePickerView.bounds.size.height;
    CGFloat addressAndTimeViewHeight = self.addressAndTimeView.bounds.size.height;
    CGFloat bottomBoundaryOffset = pickerViewHeight / 2 - addressAndTimeViewHeight / 2;
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.timePickerView]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-(bottomBoundaryOffset + 200), 0, -bottomBoundaryOffset, -1)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.timePickerView]];
    [self.animator addBehavior:self.gravityBehavior];
    
    self.timePickerPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.timePickerView] mode:UIPushBehaviorModeInstantaneous];
    self.timePickerPushBehavior.magnitude = 0.0f;
    self.timePickerPushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.timePickerPushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.timePickerView]];
    itemBehaviour.elasticity = 0.45f;
    [self.animator addBehavior:itemBehaviour];
    
    self.timePickerPushBehavior.pushDirection = CGVectorMake(0.0f, 5.0f);
    self.timePickerPushBehavior.active = YES;
}

- (void)bounceAddressLabel {
    NSLog(@"bouncing address label");
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.addressAndTimeView];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.addressLabel]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-200, -0.2, -1, 0)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.addressLabel]];
    [self.animator addBehavior:self.gravityBehavior];
    
    self.addressLabelPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.addressLabel] mode:UIPushBehaviorModeInstantaneous];
    self.addressLabelPushBehavior.magnitude = 0.0f;
    self.addressLabelPushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.addressLabelPushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.addressLabel]];
    itemBehaviour.elasticity = 0.45f;
    [self.animator addBehavior:itemBehaviour];
    
    self.addressLabelPushBehavior.pushDirection = CGVectorMake(0.0f, 2.0f);
    self.addressLabelPushBehavior.active = YES;
}

- (void)dimAddressLabel {
    [UIView transitionWithView:self.addressLabel duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.addressLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    } completion:nil];
}

- (void)unDimAddressLabel {
    [UIView transitionWithView:self.addressLabel duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.addressLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    } completion:nil];
}

- (void)dimTimeLabel {
    [UIView transitionWithView:self.timePickerView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.timePickerView.alpha = 0.5;
    } completion:nil];
}

- (void)unDimTimeLabel {
    [UIView transitionWithView:self.timePickerView duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.timePickerView.alpha = 1.0;
    } completion:nil];
}

- (void)hideAddressButtonBackground {
    self.addressButtonBackground.alpha = 0.0;
    self.addressButtonBackground.hidden = YES;
}

- (void)hideTimeButtonBackground {
    [UIView transitionWithView:self.timeButtonBackground duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.timeButtonBackground.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.timeButtonBackground.hidden = YES;
    }];
}

- (void)setup {
    // set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckoutOrderItemCell" bundle:nil] forCellReuseIdentifier:@"CheckoutOrderItemCell"];
    [self.tableView reloadData];
    
    // initialize button
    self.checkoutOrderButton.delegate = self;
    
    // initialize time picker view
    self.timeOptionTitles = @[@"Set time",
                              @"11:00am",
                              @"11:30am",
                              @"12:00pm",
                              @"12:30pm",
                              @"1:00pm",
                              @"1:30pm",
                              @"2:00pm"];
    self.timePickerDateFormatter = [[NSDateFormatter alloc] init];
    [self.timePickerDateFormatter setDateFormat:@"hh:mma"];
    
    // populate corresponding date objects (UTC)
    NSMutableArray *mutableTimeOptionDateObjects = [NSMutableArray array];
    for (NSString *dateString in self.timeOptionTitles) {
        NSDate *date = [self.timePickerDateFormatter dateFromString:dateString];
        if (date) {
            [mutableTimeOptionDateObjects addObject: date];
            
        } else {
            NSDate *dummyDate = [NSDate dateWithTimeIntervalSince1970:0];
            [mutableTimeOptionDateObjects addObject: dummyDate];
        }
    }
    self.timeOptionDateObjects = [NSArray arrayWithArray:mutableTimeOptionDateObjects];
    //    NSLog(@"date objects: %@", self.timeOptionDateObjects);
    
    self.timePickerView.dataSource = self;
    self.timePickerView.delegate = self;
    
    // set up viewcontrollers
    self.locationSelectViewController = [[LocationSelectViewController alloc] init];
    self.locationSelectViewController.delegate = self;
    
    self.paymentViewController = [[PaymentViewController alloc] init];
    self.paymentViewController.delegate = self;
}

#pragma mark - ViewController presentation methods

- (void)displayViewControllerAnimatedFromBottom:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    
    // define initial and final frames
    CGRect finalFrame = [self frameForModalViewController];
    CGRect initialFrame = finalFrame;
    initialFrame.origin.y += initialFrame.size.height;
    viewController.view.frame = initialFrame;
    
    [self.view addSubview:viewController.view];
    
    // set shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewController.view.bounds];
    viewController.view.layer.masksToBounds = NO;
    viewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    viewController.view.layer.shadowRadius = 6;
    viewController.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    viewController.view.layer.shadowOpacity = 0.3;
    viewController.view.layer.shadowPath = shadowPath.CGPath;
    
    // animate transition
    [UIView mt_animateWithViews:@[viewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         viewController.view.frame = finalFrame;
                     } completion:^{
                         // complete the transition
                         [viewController didMoveToParentViewController:self];
                     }];
}

- (void)displayViewControllerAnimatedFromRight:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    
    // define initial and final frames
    CGRect finalFrame = [self frameForModalViewController];
    CGRect initialFrame = finalFrame;
    initialFrame.origin.x += initialFrame.size.width;
    viewController.view.frame = initialFrame;
    
    [self.view addSubview:viewController.view];
    
    // set shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewController.view.bounds];
    viewController.view.layer.masksToBounds = NO;
    viewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    viewController.view.layer.shadowRadius = 6;
    viewController.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    viewController.view.layer.shadowOpacity = 0.3;
    viewController.view.layer.shadowPath = shadowPath.CGPath;
    
    // animate transition
    [UIView mt_animateWithViews:@[viewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         viewController.view.frame = finalFrame;
                     } completion:^{
                         // complete the transition
                         [viewController didMoveToParentViewController:self];
                     }];
}

- (void)hideViewControllerAnimateToBottom:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    
    CGRect finalFrame = [self frameForModalViewController];
    finalFrame.origin.y += finalFrame.size.height;
    
    [UIView mt_animateWithViews:@[viewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         viewController.view.frame = finalFrame;
                     } completion:^{
                         [viewController.view removeFromSuperview];
                         [viewController removeFromParentViewController];
                     }];
}


- (void)hideViewControllerAnimateToRight:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    
    CGRect finalFrame = [self frameForModalViewController];
    finalFrame.origin.x += finalFrame.size.width + (self.view.frame.size.width - finalFrame.size.width) / 2;
    
    [UIView mt_animateWithViews:@[viewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         viewController.view.frame = finalFrame;
                     } completion:^{
                         [viewController.view removeFromSuperview];
                         [viewController removeFromParentViewController];
                     }];
}

- (void)displayPopupViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    viewController.view.frame = [self frameForPopupViewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

- (CGRect)frameForModalViewController {
    CGFloat parentWidth = self.view.bounds.size.width;
    CGFloat parentHeight = self.view.bounds.size.height;
    CGFloat horizontalGapSize = 10.0;
    CGFloat navigationBarHeight = 64;
    
    return CGRectMake(horizontalGapSize, navigationBarHeight + horizontalGapSize, parentWidth - horizontalGapSize * 2, parentHeight - horizontalGapSize - navigationBarHeight);
}

- (CGRect)frameForPopupViewController {
    CGFloat popupWidth = 240;
    CGFloat popupHeight = 280;
    CGFloat parentWidth = self.view.bounds.size.width;
    CGFloat parentHeight = self.view.bounds.size.height;
    
    CGRect popupFrame = CGRectMake(parentWidth / 2.0 - popupWidth / 2.0,
                                   parentHeight / 2.0 - popupHeight / 2.0,
                                   popupWidth,
                                   popupHeight);
    return popupFrame;
}

@end
