//
//  DaySelectAnimationController.h
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DayCell.h"

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypePresent = 0,
    AnimationTypeDismiss = 1,
};

@interface DaySelectAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) DayCell *selectedCell;
@property (assign, nonatomic) CGPoint contentOffset;
@property (assign, nonatomic) AnimationType animationType;

@end
