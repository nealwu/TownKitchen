//
//  CheckoutAnimationController.h
//  TownKitchen
//
//  Created by Peter Bai on 3/17/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypePresent = 0,
    AnimationTypeDismiss = 1,
};

@interface CheckoutAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) AnimationType animationType;

@end
