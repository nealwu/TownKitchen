//
//  DaySelectAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectAnimationController.h"
#import "TKHeader.h"

@interface DaySelectAnimationController ()

@property (strong, nonatomic) UIViewController *fromViewController;
@property (strong, nonatomic) UIViewController *toViewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation DaySelectAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 3.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
self.containerView = [transitionContext containerView];

    TKHeader *header = [[TKHeader alloc] initWithFrame:CGRectMake(0, 0, self.fromViewController.view.frame.size.width, 64)];
    
    
    // Create snapshot images of tableview
    CGRect selectedCellFrame = self.selectedCell.frame;
    selectedCellFrame.origin.y += (self.contentOffset.y + header.frame.size.height);
    
    // Selected cell
    UIImageView *selectedCellImageView = [self imageViewFromSelectedCellFrame:selectedCellFrame];
    [self.containerView addSubview:selectedCellImageView];
    
    // Above cells
    UIImageView *aboveCellsImageView = [self imageViewFromCellsAboveSelectedCellFrame:selectedCellFrame];
    [self.containerView addSubview:aboveCellsImageView];
    
    // Below cells
    UIImageView *belowCellsImageView = [self imageViewFromCellsBelowSelectedCellFrame:selectedCellFrame];
    [self.containerView addSubview:belowCellsImageView];
    
    // Hide the original tableview
    self.fromViewController.view.alpha = 0.3;
    
    // Set final frames
    CGRect finalFrame = [transitionContext finalFrameForViewController:self.toViewController];
    
    // Set initial frames
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.toViewController.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);

    
    [self.containerView addSubview:self.toViewController.view];
    [self.containerView addSubview:header];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         self.toViewController.view.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         self.fromViewController.view.alpha = 1.0;
                         [transitionContext completeTransition:YES];
                     }];
}

#pragma mark - Helper Methods


- (UIImageView *)imageViewFromSelectedCellFrame:(CGRect)selectedCellFrame {
    UIImageView *selectedCellImageView = [[UIImageView alloc] initWithFrame:selectedCellFrame];
    selectedCellImageView.image = [self imageInRect:selectedCellFrame fromView:self.fromViewController.view];
    return selectedCellImageView;
}

- (UIImageView *)imageViewFromCellsAboveSelectedCellFrame:(CGRect)selectedCellFrame {
    CGFloat distanceAboveSelectedCell = fmaxf(0, selectedCellFrame.origin.y);
    CGRect aboveCellsFrame = CGRectMake(0, 0, self.fromViewController.view.frame.size.width, distanceAboveSelectedCell);
    UIImageView *aboveCellsImageView = [[UIImageView alloc] initWithFrame:aboveCellsFrame];
    aboveCellsImageView.image = [self imageInRect:aboveCellsFrame fromView:self.fromViewController.view];
    return aboveCellsImageView;
}

- (UIImageView *)imageViewFromCellsBelowSelectedCellFrame:(CGRect)selectedCellFrame {
    CGFloat yPositionOfSelectedCellBottomEdge = selectedCellFrame.origin.y + selectedCellFrame.size.height;
    CGFloat distanceBelowSelectedCell =
        fmaxf(0, self.fromViewController.view.frame.size.height - yPositionOfSelectedCellBottomEdge);
    CGRect belowCellsFrame = CGRectMake(0, yPositionOfSelectedCellBottomEdge, self.fromViewController.view.frame.size.width, distanceBelowSelectedCell);
    UIImageView *belowCellsImageView = [[UIImageView alloc] initWithFrame:belowCellsFrame];
    belowCellsImageView.image = [self imageInRect:belowCellsFrame fromView:self.fromViewController.view];
    return belowCellsImageView;
}

- (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.bounds.size.width, view.bounds.size.height), view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageInRect:(CGRect)rect fromView:(UIView *)view {
    UIImage *viewImage = [self imageFromView:view];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGImageRef image = CGImageCreateWithImageInRect(viewImage.CGImage, CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale));
    UIImage *imageInRect = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return imageInRect;
}

@end
