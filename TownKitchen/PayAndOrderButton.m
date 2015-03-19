//
//  PayAndOrderButton.m
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PayAndOrderButton.h"
#import "AppDelegate.h"

@implementation PayAndOrderButton

- (void)setButtonState:(ButtonState)buttonState {
    _buttonState = buttonState;
    if (buttonState == ButtonStatePlaceOrder) {
        self.backgroundColor = [UIColor redColor];
    }
    else if (buttonState == ButtonStateEnterPayment) {
        self.backgroundColor = kTKSecondaryOrangeColor
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
}
@end
