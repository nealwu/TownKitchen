//
//  DaySelectAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectAnimationController.h"
#import "TKHeader.h"

@implementation DaySelectAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 3.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    TKHeader *header = [[TKHeader alloc] initWithFrame:CGRectMake(0, 0, fromViewController.view.frame.size.width, 64)];
    
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    toViewController.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
    
    CGRect selectedCellFrame = self.selectedCell.frame;
    selectedCellFrame.origin.y += (self.contentOffset.y + header.frame.size.height);
    
    UIView *testOverlayView = [[UIView alloc] initWithFrame: selectedCellFrame];
    testOverlayView.backgroundColor = [UIColor redColor];
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:header];
    [containerView addSubview:testOverlayView];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         toViewController.view.frame = finalFrame;
                         fromViewController.view.alpha = 0.5;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                     }];
}

@end