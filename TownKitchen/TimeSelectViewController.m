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
    self.datePicker.datePickerMode = UIDatePickerModeTime;
}

#pragma mark Actions

- (IBAction)onSetTime:(id)sender {
    [self.delegate timeSelectViewController:self didSetDate:self.datePicker.date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDatePickerChanged:(id)sender {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
//    NSLog(@"%@", currentTime);
}


@end
