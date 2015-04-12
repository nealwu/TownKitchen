//
//  DeliveryButton.m
//  TownKitchen
//
//  Created by Peter Bai on 4/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DeliveryButton.h"
#import <POP.h>

@implementation DeliveryButton


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


#pragma mark - Custom Setters

- (void)setActive:(BOOL)active {
    _active = active;
    if (active) {
        [self setButtonState:ButtonStateActive animated:NO];
    } else {
        [self setButtonState:ButtonStateInactive animated:NO];
    }
}

- (void)setup {
    [self setImage:[UIImage imageNamed:@"map-button"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"map-button-highlighted"] forState:UIControlStateHighlighted];
}

- (void)setButtonState:(ButtonState)state animated:(BOOL)animated {
    switch (state) {
        case ButtonStateInactive: {
            self.userInteractionEnabled = NO;
            if (animated) {
                self.layer.opacity = 0.5;
            } else {
                self.layer.opacity = 0.5;
            }
            break;
        }
        case ButtonStateActive: {
            self.userInteractionEnabled = YES;
            if (animated) {
                [self animateToActiveState];
            } else {
                self.layer.opacity = 1.0;
            }
            break;
        }
        default:
            break;
    }
}

- (void)animateToActiveState {
    POPBasicAnimation *scaleSmallAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleSmallAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.8f, 0.8f)];
    scaleSmallAnimation.duration = 0.3;
    scaleSmallAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    POPSpringAnimation *scaleSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleSpringAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(20.f, 20.f)];
    scaleSpringAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleSpringAnimation.springBounciness = 20.0f;

    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(1.0);
    opacityAnimation.duration = 0.2;
    
    [scaleSmallAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [self.layer pop_addAnimation:scaleSpringAnimation forKey:@"layerScaleSpringAnimation"];
        [self.layer pop_addAnimation:opacityAnimation forKey:@"layerFullOpacityAnimation"];
    }];
    [self.layer pop_addAnimation:scaleSmallAnimation forKey:@"layerScaleSmallAnimation"];
}

@end
