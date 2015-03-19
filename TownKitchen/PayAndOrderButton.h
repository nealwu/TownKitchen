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

@class PayAndOrderButton;

@protocol PayAndOrderButtonDelegate <NSObject>

- (void)onPayAndOrderButton:(PayAndOrderButton *)button withButtonState:(ButtonState)buttonState;

@end

@interface PayAndOrderButton : UIButton

@property (assign, nonatomic) ButtonState buttonState;
@property (weak, nonatomic) id<PayAndOrderButtonDelegate> delegate;

@end
