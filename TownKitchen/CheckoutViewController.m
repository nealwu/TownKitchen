//
//  CheckoutViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 4/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutViewController.h"

#import "AddressInputViewController.h"
#import "CheckoutOrderItemCell.h"
#import "MenuOption.h"
#import "ParseAPI.h"

@interface CheckoutViewController () <UITableViewDataSource, UITableViewDelegate, CheckoutOrderButtonDelegate, UIPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

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

@property (assign, nonatomic) BOOL didSetTime;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIPushBehavior *timePickerPushBehavior;
@property (strong, nonatomic) UIPushBehavior *addressLabelPushBehavior;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
//    self.timePickerView.userInteractionEnabled = NO;
    
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

- (void)setAddress:(NSString *)address {
    _address = address;
    self.didSetAddress = YES;
}

- (void)setDidSetAddress:(BOOL)didSetAddress {
    _didSetAddress = didSetAddress;
    if (didSetAddress) {
        [self hideAddressButtonBackground];
    }
}

- (void)setDeliveryTime:(NSDate *)deliveryTime {
    _deliveryTime = deliveryTime;
    
    NSDateComponents *deliveryTimeComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:deliveryTime];
    
    [self.timeOptionDateObjects enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
        NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
        if (deliveryTimeComponents.hour == timeComponents.hour &&
            deliveryTimeComponents.minute == timeComponents.minute) {
            NSLog(@"found match at index %d: %@, %@", idx, deliveryTimeComponents, timeComponents);
            [self.timePickerView selectRow:idx inComponent:0 animated:NO];
            [self pickerView:self.timePickerView didSelectRow:idx inComponent:0];
            *stop = YES;
        }
    }];

    [self hideTimeButtonBackgroundInstant];
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

#pragma mark - CheckoutOrderButtonDelegate Methods

- (void)onCheckoutOrderButton:(CheckoutOrderButton *)button withButtonState:(ButtonState)buttonState {
    if (buttonState == ButtonStateEnterPayment) {
        [self.delegate paymentButtonPressedFromCheckoutViewController:self];
        
    } else if (buttonState == ButtonStatePlaceOrder) {
        if ([self validateInput]){
            [self.delegate orderButtonPressedFromCheckoutViewController:self];
        }
    }
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
        [[ParseAPI getInstance] setCurrentUserPreferredTime:[calendar dateFromComponents:dayComponents]];

        self.didSetTime = YES;
    }
}

#pragma mark - Actions

- (IBAction)onAddressButton:(UIButton *)sender {
    [self.delegate addressButtonPressedFromCheckoutViewController:self];
    [self unDimAddressLabel];
}

- (IBAction)onAddressButtonTouchDown:(UIButton *)sender {
    [self dimAddressLabel];
}

- (IBAction)onAddressButtonTouchDragOutside:(UIButton *)sender {
    [self unDimAddressLabel];
}

- (IBAction)onTimeButton:(UIButton *)sender {
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
    self.timeButton.hidden = YES;
    [UIView transitionWithView:self.timeButtonBackground duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.timeButtonBackground.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.timeButtonBackground.hidden = YES;
    }];
}

- (void)hideTimeButtonBackgroundInstant {
    self.timeButton.hidden = YES;
    self.timeButtonBackground.alpha = 0.0;
    self.timeButtonBackground.hidden = YES;
}

@end
