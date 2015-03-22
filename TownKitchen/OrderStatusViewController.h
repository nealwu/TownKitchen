//
//  OrderStatusViewController.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@class OrderStatusViewController;

@protocol OrderStatusViewControllerDelegate

- (void)orderStatusViewControllerShouldBeDismissed:(OrderStatusViewController *)orderStatusViewController;

@end

@interface OrderStatusViewController : UIViewController

@property (weak, nonatomic) id<OrderStatusViewControllerDelegate> delegate;
@property (strong, nonatomic) Order *order;
@property (nonatomic) BOOL reportLocationAsDriverLocation;

@end
