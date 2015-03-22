//
//  OrdersViewController.h
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrdersViewController;

@protocol OrdersViewControllerDelegate

- (void)ordersViewControllerShouldBeDismissed:(OrdersViewController *)ordersViewController;

@end

@interface OrdersViewController : UIViewController

@property (weak, nonatomic) id<OrdersViewControllerDelegate> delegate;

@end
