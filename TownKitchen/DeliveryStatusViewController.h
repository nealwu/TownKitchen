//
//  DeliveryStatusViewController.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class DeliveryStatusViewController;

@protocol DeliveryStatusViewControllerDelegate

- (void)deliveryStatusViewControllerShouldBeDismissed:(DeliveryStatusViewController *)deliveryStatusViewController;

@end

@interface DeliveryStatusViewController : UIViewController

@property (weak, nonatomic) id<DeliveryStatusViewControllerDelegate> delegate;
@property (strong, nonatomic) PFUser *driver;

@end
