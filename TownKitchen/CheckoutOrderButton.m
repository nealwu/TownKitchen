//
//  PayAndOrderButton.m
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutOrderButton.h"
#import "UIColor+TKColorPalette.h"

@implementation CheckoutOrderButton

- (void)setButtonState:(ButtonState)buttonState {
    _buttonState = buttonState;
    
    switch (buttonState) {
        case ButtonStateEnterPayment: {
            self.backgroundColor = [UIColor TKOrangeColor];
            [self setTitle:@"Enter Payment Info" forState:UIControlStateNormal];
            self.titleLabel.alpha = 1.0;
            break;
        }
        case ButtonStatePlaceOrderInactive: {
            self.backgroundColor = [UIColor TKRedColor];
            [self setTitle:@"Place Order" forState:UIControlStateNormal];
            self.titleLabel.alpha = 0.5;
            break;
        }
        case ButtonStatePlaceOrder: {
            self.backgroundColor = [UIColor TKRedColor];
            [self setTitle:@"Place Order" forState:UIControlStateNormal];
            self.titleLabel.alpha = 1.0;
            break;
        }
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(onButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)animateButtonToState:(ButtonState)buttonState {
    switch (buttonState) {
        case ButtonStatePlaceOrder: {
            [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.titleLabel.alpha = 1.0;
            } completion:^(BOOL finished) {
                self.buttonState = ButtonStatePlaceOrder;
            }];
            break;
        }
        default:
            NSLog(@"CheckoutOrderButton animation to state %d has not yet been implemented!", buttonState);
            break;
    }
}

- (void)onButton {
    [self.delegate onCheckoutOrderButton:self withButtonState:self.buttonState];
}

@end
