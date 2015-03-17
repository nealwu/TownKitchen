//
//  DaySelectAnimationController.m
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DaySelectAnimationController.h"
#import "TKHeader.h"
#import "DayCell.h"
#import <FXBlurView.h>
#import "DateLabelsView.h"

CGFloat const transitionImageInitialHeight = 130;
CGFloat const transitionImageFinalHeight = 200;
CGFloat const transitionImageYPositionAdjustment = 99.0;
CGFloat const statusBarHeight = 20.0;

@interface DaySelectAnimationController ()

@property (strong, nonatomic) UIViewController *fromViewController;
@property (strong, nonatomic) UIViewController *toViewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation DaySelectAnimationController

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

#pragma mark - Animations

- (void)animateTransitionPresent:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Create intermediate header
    TKHeader *header = [[TKHeader alloc] initWithFrame:CGRectMake(0, 0, self.fromViewController.view.frame.size.width, 64)];
    UIImageView *TKLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-logo"]];
    [header.titleView addSubview:TKLogoImageView];
    
    // Define snapshot frame
    CGRect selectedCellFrame = self.selectedCell.frame;
    CGRect selectedCellBounds = self.selectedCell.bounds;
    selectedCellFrame.origin.y += (header.frame.size.height - self.contentOffset.y);
    
    // Create transition view with same frame as toVC's image
    CGFloat imageCenterYDelta = transitionImageFinalHeight / 2 - selectedCellFrame.size.height / 2;
    UIView *transitionView = [[UIView alloc] initWithFrame:CGRectMake(selectedCellFrame.origin.x,
                                                                      selectedCellFrame.origin.y - imageCenterYDelta,
                                                                      selectedCellFrame.size.width,
                                                                      transitionImageFinalHeight)];
    
    UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:transitionView.bounds];
    transitionImageView.image = self.selectedCell.darkenedImage;
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    transitionImageView.clipsToBounds = YES;
    
    [transitionView addSubview:transitionImageView];
    [self.containerView addSubview:transitionView];
    
    // Create dateLabels view for transition from cell to header
    DateLabelsView *dateLabelsView = [[DateLabelsView alloc] initWithFrame:CGRectMake(selectedCellFrame.origin.x,
                                                                                      selectedCellFrame.origin.y,
                                                                                      selectedCellFrame.size.width,
                                                                                      selectedCellFrame.size.height)];
    dateLabelsView.weekdayLabel.text = self.selectedCell.weekday;
    dateLabelsView.monthAndDayLabel.text = self.selectedCell.monthAndDay;
    
    // Snapshot cells above selected cell
    UIImageView *aboveCellsImageView = [self imageViewFromCellsAboveSelectedCellFrame:selectedCellFrame inViewController:self.fromViewController];
    [self.containerView addSubview:aboveCellsImageView];
    
    // Snapshot cells below selected cell
    UIImageView *belowCellsImageView = [self imageViewFromCellsBelowSelectedCellFrame:selectedCellFrame inViewController:self.fromViewController];
    [self.containerView addSubview:belowCellsImageView];
    
    // Hide the original tableview
    self.fromViewController.view.hidden = YES;
    
    // Add subviews that need to be on top
    [self.containerView addSubview:header];
    [self.containerView addSubview:dateLabelsView];
    
    // Set initial frames
    CGRect initialToFrame = self.toViewController.view.frame;
    self.toViewController.view.frame = CGRectMake(initialToFrame.origin.x, selectedCellFrame.origin.y - transitionImageYPositionAdjustment, initialToFrame.size.width, initialToFrame.size.height);
    
    // Define final frames
    CGRect finalToFrame = [transitionContext finalFrameForViewController:self.toViewController];
    CGRect finalTransitionImageFrame = CGRectMake(selectedCellFrame.origin.x, header.frame.size.height, selectedCellFrame.size.width, transitionImageFinalHeight);
    CATransform3D headerTitleTransform = CATransform3DIdentity;
    headerTitleTransform = CATransform3DTranslate(headerTitleTransform, 0, - (1.5 * header.frame.size.height), 0);
    
    // Define final transforms (date label)
    CGFloat scaleFactor = 0.5;
    CGFloat yToOffsetAfterScaling = 8.5;
    CGAffineTransform dateLabelsViewTransform = CGAffineTransformIdentity;
    CGFloat dateLabelDisplacementY = selectedCellFrame.origin.y + (dateLabelsView.frame.size.height * scaleFactor) / 2.0 - statusBarHeight + yToOffsetAfterScaling;
    dateLabelsViewTransform = CGAffineTransformTranslate(dateLabelsViewTransform, 0, - dateLabelDisplacementY);
    dateLabelsViewTransform = CGAffineTransformScale(dateLabelsViewTransform, 0.5, 0.5);
    
    CGFloat monthAndDayLabelDisplacementY = 5.0;
    CGAffineTransform monthAndDayLabelTransform = CGAffineTransformMakeTranslation(0, - monthAndDayLabelDisplacementY);
    
    // Animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         aboveCellsImageView.center = CGPointMake(aboveCellsImageView.center.x, aboveCellsImageView.center.y - aboveCellsImageView.frame.size.height + header.frame.size.height);
                         belowCellsImageView.center = CGPointMake(belowCellsImageView.center.x, belowCellsImageView.center.y + belowCellsImageView.frame.size.height);
                         
                         transitionView.frame = finalTransitionImageFrame;
                         
                         header.titleView.layer.transform = headerTitleTransform;
                         dateLabelsView.transform = dateLabelsViewTransform;
                         dateLabelsView.monthAndDayLabel.transform = monthAndDayLabelTransform;
                         
                         self.toViewController.view.frame = finalToFrame;
                     }
                     completion:^(BOOL finished) {
                         self.fromViewController.view.hidden = NO;
                         transitionImageView.hidden = YES;
                         [transitionContext completeTransition:YES];
                     }];
    
    // Animate image view faster
    [UIView animateWithDuration:duration * 0.5
                     animations:^{
                         transitionImageView.alpha = 0.0;
                     }];
}

- (void)animateTransitionDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {
    
}

#pragma mark - Helper Methods


- (UIImageView *)imageViewFromSelectedCellFrame:(CGRect)selectedCellFrame inViewController:(UIViewController *)viewController {
    UIImageView *selectedCellImageView = [[UIImageView alloc] initWithFrame:selectedCellFrame];
    selectedCellImageView.image = [self imageInRect:selectedCellFrame fromView:viewController.view];
    return selectedCellImageView;
}

- (UIImageView *)imageViewFromCellsAboveSelectedCellFrame:(CGRect)selectedCellFrame inViewController:(UIViewController *)viewController {
    CGFloat distanceAboveSelectedCell = fmaxf(0, selectedCellFrame.origin.y);
    CGRect aboveCellsFrame = CGRectMake(0, 0, viewController.view.frame.size.width, distanceAboveSelectedCell);
    UIImageView *aboveCellsImageView = [[UIImageView alloc] initWithFrame:aboveCellsFrame];
    aboveCellsImageView.image = [self imageInRect:aboveCellsFrame fromView:viewController.view];
    return aboveCellsImageView;
}

- (UIImageView *)imageViewFromCellsBelowSelectedCellFrame:(CGRect)selectedCellFrame inViewController:(UIViewController *)viewController {
    CGFloat yPositionOfSelectedCellBottomEdge = selectedCellFrame.origin.y + selectedCellFrame.size.height;
    CGFloat distanceBelowSelectedCell =
        fmaxf(0, viewController.view.frame.size.height - yPositionOfSelectedCellBottomEdge);
    CGRect belowCellsFrame = CGRectMake(0, yPositionOfSelectedCellBottomEdge, viewController.view.frame.size.width, distanceBelowSelectedCell);
    UIImageView *belowCellsImageView = [[UIImageView alloc] initWithFrame:belowCellsFrame];
    belowCellsImageView.image = [self imageInRect:belowCellsFrame fromView:viewController.view];
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
