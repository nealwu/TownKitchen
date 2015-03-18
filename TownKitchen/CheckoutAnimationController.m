//
//  CheckoutAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/17/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutAnimationController.h"

@interface CheckoutAnimationController ()

@property (strong, nonatomic) UIViewController *fromViewController;
@property (strong, nonatomic) UIViewController *toViewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation CheckoutAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.containerView = [transitionContext containerView];
    [self.containerView insertSubview:self.toViewController.view aboveSubview:self.fromViewController.view];
    
    if (self.animationType == AnimationTypePresent) {
        [self animateTransitionPresent:transitionContext];
    }
    else {
        [self animateTransitionDismiss:transitionContext];
    }
}

- (void)animateTransitionPresent:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    CGRect endFrame = self.toViewController.view.frame;
    CGRect startFrame = endFrame;
    startFrame.origin.x += 320;
    self.toViewController.view.frame = startFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.toViewController.view.alpha = 1.0;
        self.toViewController.view.frame = endFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {

}


@end
