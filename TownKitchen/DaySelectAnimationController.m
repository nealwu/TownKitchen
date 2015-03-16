//
//  DaySelectAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectAnimationController.h"

@implementation DaySelectAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 3.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds]; toViewController.view.frame =
    CGRectOffset(finalFrame, 0, screenBounds.size.height); // 4. add the view
    [containerView addSubview:toViewController.view];
    NSTimeInterval duration =
    [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.frame = finalFrame; } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES]; }];
}

@end
