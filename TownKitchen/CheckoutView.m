//
//  CheckoutView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutView.h"
#import "CheckoutOrderItemCell.h"
#import "MenuOption.h"

@interface CheckoutView () <UITableViewDataSource, UITableViewDelegate, PayAndOrderButtonDelegate, UIPickerViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView *timePickerView;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (strong, nonatomic) NSArray *timeOptionTitles;
@property (strong, nonatomic) NSArray *timeOptionDateObjects;

@end

@implementation CheckoutView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    // Load nib
    UINib *nib = [UINib nibWithNibName:@"CheckoutView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    
    // set up tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckoutOrderItemCell" bundle:nil] forCellReuseIdentifier:@"CheckoutOrderItemCell"];
    [self.tableView reloadData];

    // initialize button
    self.payAndOrderButton.delegate = self;
    
    // initialize time picker view
    self.timeOptionTitles = @[@"Set time",
                              @"11:00am",
                              @"11:30am",
                              @"12:00pm",
                              @"12:30pm",
                              @"1:00pm",
                              @"1:30pm",
                              @"2:00pm"];
    self.timePickerView.dataSource = self;
    self.timePickerView.delegate = self;
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
    self.payAndOrderButton.buttonState = buttonState;
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
    
    return cell;
}

#pragma mark - PayAndOrderButtonDelegate Methods

- (void)onPayAndOrderButton:(PayAndOrderButton *)button withButtonState:(ButtonState)buttonState {
    if (buttonState == ButtonStateEnterPayment) {
        [self.delegate paymentButtonPressedFromCheckoutView:self];
        
    } else if (buttonState == ButtonStatePlaceOrder) {
        [self.delegate orderButtonPressedFromCheckoutView:self];
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
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 32;  // taller than parent view height to hide selection bars
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"picker selected row %ld with title %@", (long)row, self.timeOptionTitles[row]);
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Actions

- (IBAction)onTimePickerViewTapped:(UITapGestureRecognizer *)sender {
    // scroll two rows to show that more options exist
    if ([self.timePickerView selectedRowInComponent:0] == 0) {
        [self.timePickerView selectRow:2 inComponent:0 animated:YES];
    }
}

@end
