//
//  OrderConfirmationViewController.h
//  TownKitchen
//
//  Created by Peter Bai on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderConfirmationViewController;

@protocol OrderConfirmationViewControllerDelegate <NSObject>

- (void)onDoneButtonTappedFromOrderConfirmationViewController:(OrderConfirmationViewController *)viewController;

@end

@interface OrderConfirmationViewController : UIViewController

@property (strong, nonatomic) NSString *email;
@property (weak, nonatomic) id<OrderConfirmationViewControllerDelegate> delegate;

@end
