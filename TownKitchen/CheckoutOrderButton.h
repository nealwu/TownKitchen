//
//  PayAndOrderButton.h
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonState) {
    ButtonStateEnterPayment = 1,
    ButtonStatePlaceOrder = 2
};

@class CheckoutOrderButton;

@protocol CheckoutOrderButtonDelegate <NSObject>

- (void)onCheckoutOrderButton:(CheckoutOrderButton *)button withButtonState:(ButtonState)buttonState;

@end

@interface CheckoutOrderButton : UIButton

@property (assign, nonatomic) ButtonState buttonState;
@property (weak, nonatomic) id<CheckoutOrderButtonDelegate> delegate;

@end
