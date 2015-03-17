//
//  TimeSelectViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "TimeSelectViewController.h"

@interface TimeSelectViewController ()

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

@end
