//
//  TimeSelectViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "TimeSelectViewController.h"

@interface TimeSelectViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *timePickerView;

@property (strong, nonatomic) NSArray *timeOptionTitles;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *timePickerTapGestureRecognizer;

@end

@implementation TimeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private Methods

- (void)setup {
    
    self.timeOptionTitles = @[@"Set time", @"11:00am", @"11:30am", @"12:00pm", @"12:30pm", @"1:00pm", @"1:30pm", @"2:00pm"];
    self.timePickerView.dataSource = self;
    self.timePickerView.delegate = self;
    
    // Orders can be between 11 am and 2 pm
    int startHour = 11;
    int endHour = 14;

    NSDate *date1 = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date1];
    [components setHour:startHour];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startDate = [calendar dateFromComponents:components];

    [components setHour:endHour];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *endDate = [calendar dateFromComponents:components];

    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.minimumDate = startDate;
    self.datePicker.maximumDate = endDate;
    self.datePicker.minuteInterval = 30;
}

#pragma mark Actions

- (IBAction)onSetTime:(id)sender {
    [self.delegate timeSelectViewController:self didSetTime:self.datePicker.date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTimePickerViewTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"picker view tapped!");
    [self.timePickerView selectRow:1 inComponent:1 animated:YES];
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
        label.textColor = [UIColor redColor];
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 32;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"picker selected row %ld with title %@", (long)row, self.timeOptionTitles[row]);
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.timeOptionTitles.count;
}

@end
