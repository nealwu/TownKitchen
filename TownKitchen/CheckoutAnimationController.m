//
//  CheckoutAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/17/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutAnimationController.h"
#import "TKHeader.h"

CGFloat const statusAndNavBarHeight = 64.0;

@interface CheckoutAnimationController ()

@property (strong, nonatomic) UIViewController *fromViewController;
@property (strong, nonatomic) UIViewController *toViewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation CheckoutAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.containerView = [transitionContext containerView];
    [self.containerView addSubview:self.toViewController.view];
    // do not need add fromViewController, or view will blank out after transition completes
    
    if (self.animationType == AnimationTypePresent) {
        [self animateTransitionPresent:transitionContext];
    }
    else {
        [self animateTransitionDismiss:transitionContext];
    }
}

- (void)animateTransitionPresent:(id<UIViewControllerContextTransitioning>)transitionContext {
    // create header for container view// set up header
    TKHeader *header = [[TKHeader alloc] initWithFrame:CGRectMake(0, 0, self.fromViewController.view.frame.size.width, 64)];
    
    DateLabelsViewSmall *dateLabelsViewSmall = [[DateLabelsViewSmall alloc] initWithFrame:header.titleView.bounds];
    dateLabelsViewSmall.weekdayLabel.text = self.dateLabelsViewSmall.weekdayLabel.text;
    dateLabelsViewSmall.monthAndDayLabel.text = self.dateLabelsViewSmall.monthAndDayLabel.text;
    [header.titleView addSubview:dateLabelsViewSmall];
    
    [self.containerView addSubview:header];
    
    // size up the checkout view
    
    CGRect endFrame = self.toViewController.view.frame;
//    endFrame.size.height -= statusAndNavBarHeight;
//    endFrame.origin.y += statusAndNavBarHeight;
    
    CGRect startFrame = self.toViewController.view.frame;
    startFrame.origin.y += self.fromViewController.view.frame.size.height;
    self.toViewController.view.frame = startFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.toViewController.view.alpha = 1.0;
        self.toViewController.view.frame = endFrame;
        self.fromViewController.view.alpha = 0.5;
        header.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {

}


@end
