//
//  CheckoutView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayAndOrderButton.h"
#import "Order.h"

@class CheckoutView;

@protocol CheckoutViewDelegate <NSObject>

- (void)paymentButtonPressedFromCheckoutView:(CheckoutView *)view;
- (void)orderButtonPressedFromCheckoutView:(CheckoutView *)view;

@end

@interface CheckoutView : UIView

@property (weak, nonatomic) Order *order;  // orderCreationViewController owns Order object
@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (assign, nonatomic) ButtonState buttonState;
@property (weak, nonatomic) IBOutlet PayAndOrderButton *payAndOrderButton;
@property (weak, nonatomic) id<CheckoutViewDelegate> delegate;

@end
