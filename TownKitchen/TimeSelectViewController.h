//
//  TimeSelectViewController.h
//  TownKitchen
//
//  Created by Peter Bai on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeSelectViewController;

@protocol TimeSelectViewControllerDelegate <NSObject>

- (void)timeSelectViewController:(TimeSelectViewController *)tvc didSetDate:(NSDate *)date;

@end

@interface TimeSelectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id<TimeSelectViewControllerDelegate> delegate;

@end
