//
//  PayAndOrderButton.m
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PayAndOrderButton.h"
#import "UIColor+TKColorPalette.h"

@implementation PayAndOrderButton

- (void)setButtonState:(ButtonState)buttonState {
    _buttonState = buttonState;
    if (buttonState == ButtonStatePlaceOrder) {
        self.backgroundColor = [UIColor TKRedColor];
        [self setTitle:@"Place Order" forState:UIControlStateNormal];
    }
    else if (buttonState == ButtonStateEnterPayment) {
        self.backgroundColor = [UIColor TKOrangeColor];
        [self setTitle:@"Enter Payment Info" forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(onButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onButton {
    [self.delegate onPayAndOrderButton:self withButtonState:self.buttonState];
}

@end
