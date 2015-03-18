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
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.containerView = [transitionContext containerView];
    [self.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    if (self.animationType == AnimationTypePresent) {
        [self animateTransitionPresent:transitionContext];
    }
    else {
        [self animateTransitionDismiss:transitionContext];
    }
}

- (void)animateTransitionPresent:(id<UIViewControllerContextTransitioning>)transitionContext {

}

- (void)animateTransitionDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {

}


@end
