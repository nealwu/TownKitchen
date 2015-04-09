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
        case ButtonStateEnterAddess: {
//            self.backgroundColor = [UIColor TKOrangeColor];
//            [self setTitle:@"Set Address" forState:UIControlStateNormal];
            self.backgroundColor = [UIColor TKOrangeColor];
            [self setTitle:@"" forState:UIControlStateNormal];
            break;
        }
        case ButtonStateEnterTime: {
            self.backgroundColor = [UIColor TKOrangeColor];
            [self setTitle:@"Set Time" forState:UIControlStateNormal];
            break;
        }
        case ButtonStateEnterPayment: {
            self.backgroundColor = [UIColor TKOrangeColor];
            [self setTitle:@"Enter Payment Info" forState:UIControlStateNormal];
            break;
        }
        case ButtonStatePlaceOrder: {
            self.backgroundColor = [UIColor TKRedColor];
            [self setTitle:@"Place Order" forState:UIControlStateNormal];
            break;
        }
        case ButtonStateEmpty: {
            self.backgroundColor = [UIColor TKOrangeColor];
            [self setTitle:@"" forState:UIControlStateNormal];
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

- (void)onButton {
//    [self.delegate onCheckoutOrderButton:self withButtonState:self.buttonState];
    UIImageView *checkMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-checkmark"]];
    checkMark.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    [self addSubview:checkMark];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGFloat maskHeight = checkMark.layer.bounds.size.height;
    CGFloat maskWidth = checkMark.layer.bounds.size.width;
    CGFloat radius = sqrtf(maskWidth * maskWidth + maskHeight * maskHeight) / 2.0 + 10;
    CGPoint centerPoint = CGPointMake(maskWidth / 2.0, maskHeight - maskHeight * 0.1);
    
    UIBezierPath *initialCirclePath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                                     radius:0.0
                                                                 startAngle:0.0
                                                                   endAngle:M_PI * 2.0
                                                                  clockwise:YES];
    UIBezierPath *finalCirclePath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                                   radius:radius
                                                               startAngle:0.0
                                                                 endAngle:M_PI * 2.0
                                                                clockwise:YES];
    maskLayer.path = finalCirclePath.CGPath;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration=0.3;
    animation.fromValue = (id)initialCirclePath.CGPath;
    animation.toValue = (id)finalCirclePath.CGPath;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [maskLayer addAnimation:animation forKey:@"drawCircleAnimation"];
//        [checkMark.layer addSublayer:maskLayer];
    checkMark.layer.mask = maskLayer;
}

//- (UILabel *)label {
//    
//}

- (CGRect)newLabelInitialPosition {
    CGRect frame = self.frame;
    frame.origin.y += frame.size.height;
    return frame;
}

- (CGRect)oldLabelFinalPosition {
    CGRect frame = self.frame;
    frame.origin.y -= frame.size.height;
    return frame;
}


@end
