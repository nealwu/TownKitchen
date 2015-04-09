//
//  CheckoutViewController.h
//  TownKitchen
//
//  Created by Peter Bai on 4/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "PayAndOrderButton.h"

@class CheckoutViewController;

@protocol CheckoutViewControllerDelegate <NSObject>

- (void)paymentButtonPressedFromCheckoutViewController:(CheckoutViewController *)cvc;
- (void)orderButtonPressedFromCheckoutViewController:(CheckoutViewController *)cvc;
- (void)addressButtonPressedFromCheckoutViewController:(CheckoutViewController *)cvc;

@end

@interface CheckoutViewController : UIViewController

@property (weak, nonatomic) Order *order;  // orderCreationViewController owns Order object
@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (assign, nonatomic) ButtonState buttonState;
@property (weak, nonatomic) IBOutlet PayAndOrderButton *payAndOrderButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (assign, nonatomic) BOOL didSetAddress;

@property (weak, nonatomic) id<CheckoutViewControllerDelegate> delegate;

@end