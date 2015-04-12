//
//  InsetModalAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 4/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "InsetModalAnimationController.h"
#import <UIView+MTAnimation.h>

@interface InsetModalAnimationController ()

@property (strong, nonatomic) UIViewController *fromViewController;
@property (strong, nonatomic) UIViewController *toViewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation InsetModalAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.containerView = [transitionContext containerView];
    [self.containerView addSubview:self.toViewController.view];
    
    [self animateTransitionPresent:transitionContext];
}

#pragma mark - Animations

- (void)animateTransitionPresent:(id<UIViewControllerContextTransitioning>)transitionContext {
    // define initial and final frames
    CGRect finalFrame = [self frameForModalViewController];
    CGRect initialFrame = finalFrame;
    initialFrame.origin.y += initialFrame.size.height;
    self.toViewController.view.frame = initialFrame;
    
    // set shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.toViewController.view.bounds];
    self.toViewController.view.layer.masksToBounds = NO;
    self.toViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toViewController.view.layer.shadowRadius = 6;
    self.toViewController.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.toViewController.view.layer.shadowOpacity = 0.3;
    self.toViewController.view.layer.shadowPath = shadowPath.CGPath;
    
    // animate transition
    [UIView mt_animateWithViews:@[self.toViewController.view]
                       duration:0.5
                          delay:0.0
                 timingFunction:kMTEaseOutQuart
                     animations:^{
                         self.toViewController.view.frame = finalFrame;
                     } completion:^{
                         // complete the transition
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)animateTransitionDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {

}

#pragma mark - Helper methods

- (CGRect)frameForModalViewController {
    CGFloat parentWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat parentHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat horizontalGapSize = 10.0;
    CGFloat navigationBarHeight = 64;
    
    return CGRectMake(horizontalGapSize, navigationBarHeight + horizontalGapSize, parentWidth - horizontalGapSize * 2, parentHeight - horizontalGapSize - navigationBarHeight);
}

- (CGRect)frameForPopupViewController {
    CGFloat popupWidth = 240;
    CGFloat popupHeight = 280;
    CGFloat parentWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat parentHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect popupFrame = CGRectMake(parentWidth / 2.0 - popupWidth / 2.0,
                                   parentHeight / 2.0 - popupHeight / 2.0,
                                   popupWidth,
                                   popupHeight);
    return popupFrame;
}


@end
