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
#import "DateLabelsViewSmall.h"
#import <UIView+MTAnimation.h>
#import "DaySelectViewController.h"

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
    header.titleView.backgroundColor = [UIColor clearColor];
    UIImageView *TKLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-logo"]];
    [header.titleView addSubview:TKLogoImageView];
    
    // Create back button for header
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button"];
    CGRect backButtonFrame = header.leftView.bounds;
//    backButtonFrame.origin.x -= 12;
    UIButton *backButton = [[UIButton alloc] initWithFrame:backButtonFrame];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [header.leftView addSubview:backButton];
    backButton.alpha = 0;
    
    // Create profile button for header
    UIButton *profileButton = [[UIButton alloc] initWithFrame:header.leftView.bounds];
    [profileButton setImage:[UIImage imageNamed:@"user-profile-button"] forState:UIControlStateNormal];
    [header.leftView addSubview:profileButton];
    
    // Create active delivery button
    CGRect activeDeliveryButtonFrame = header.rightView.bounds;
    UIButton *activeDeliveryButton = [[UIButton alloc] initWithFrame:activeDeliveryButtonFrame];
    if ([(DaySelectViewController *)self.fromViewController activeOrder]) {
        activeDeliveryButton.alpha = 1.0;
    } else {
        activeDeliveryButton.alpha = 0.5;
    }
    [activeDeliveryButton setImage:[UIImage imageNamed:@"map-button"] forState:UIControlStateNormal];
    [header.rightView addSubview:activeDeliveryButton];
    
    // Define snapshot frame
    CGRect selectedCellFrame = self.selectedCell.frame;
    selectedCellFrame.origin.y += (header.frame.size.height - self.contentOffset.y);
    
    // Create transition view
    CGFloat imageCenterYDelta = transitionImageFinalHeight / 2 - selectedCellFrame.size.height / 2;
    UIView *transitionView = [[UIView alloc] initWithFrame:CGRectMake(selectedCellFrame.origin.x,
                                                                      selectedCellFrame.origin.y - imageCenterYDelta,
                                                                      selectedCellFrame.size.width,
                                                                      transitionImageFinalHeight)];
    
    UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:transitionView.bounds];
    transitionImageView.image = self.selectedCell.backgroundImageView.image;
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    transitionImageView.clipsToBounds = YES;
    [transitionView addSubview:transitionImageView];

    UIView *darkFilterView = [[UIView alloc] initWithFrame:transitionView.bounds];
    darkFilterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    [transitionView addSubview:darkFilterView];
    
        // add gradient to darkFilterView
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = darkFilterView.bounds;
    gradientMask.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.8].CGColor,
                            (id)[UIColor colorWithWhite:0 alpha:1.0].CGColor];
    gradientMask.locations = @[@0.57, @0.84];
    darkFilterView.layer.mask = gradientMask;
    
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
    [dateLabelsView layoutIfNeeded];
    
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
    [UIView mt_animateWithViews:@[aboveCellsImageView, belowCellsImageView, transitionView, header, header.titleView, dateLabelsView, dateLabelsView.monthAndDayLabel, backButton, self.toViewController.view]
                       duration:duration
                          delay:0.0
                 timingFunction:kMTEaseInOutCubic
                     animations:^{
                         aboveCellsImageView.center = CGPointMake(aboveCellsImageView.center.x, aboveCellsImageView.center.y - aboveCellsImageView.frame.size.height + header.frame.size.height);
                         belowCellsImageView.center = CGPointMake(belowCellsImageView.center.x, belowCellsImageView.center.y + belowCellsImageView.frame.size.height);
                         
                         transitionView.frame = finalTransitionImageFrame;
                         
                         header.titleView.layer.transform = headerTitleTransform;
                         dateLabelsView.transform = dateLabelsViewTransform;
                         dateLabelsView.monthAndDayLabel.transform = monthAndDayLabelTransform;
                         
                         self.toViewController.view.frame = finalToFrame;
                     } completion:^{
                         self.fromViewController.view.hidden = NO;
                         [transitionView removeFromSuperview];
                         [dateLabelsView removeFromSuperview];
                         [header removeFromSuperview];
                         [aboveCellsImageView removeFromSuperview];
                         [belowCellsImageView removeFromSuperview];
                         
                         [transitionContext completeTransition:YES];
                     }];
    
    [UIView mt_animateWithViews:@[transitionView]
                       duration:duration * 0.5
                          delay:0.0
                 timingFunction:kMTEaseInCubic
                     animations:^{
                         transitionView.alpha = 0.0;
                     } completion:^{
                         nil;
                     }];
    
    [UIView animateWithDuration:duration * 0.5
                     animations:^{
                         profileButton.alpha = 0.0;
                         activeDeliveryButton.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration * 0.5
                                          animations:^{
                                              backButton.alpha = 1.0;
                                          } completion:^(BOOL finished) {
                                              nil;
                                          }];
    }];
}

- (void)animateTransitionDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Create intermediate header
    TKHeader *header = [[TKHeader alloc] initWithFrame:CGRectMake(0, 0, self.fromViewController.view.frame.size.width, 64)];
    UIImageView *TKLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header-logo"]];
    [header.titleView addSubview:TKLogoImageView];
    [self.containerView addSubview:header];
    
    // Create date label
    DateLabelsViewSmall *dateLabelsViewSmall = [[DateLabelsViewSmall alloc] initWithFrame:header.titleView.bounds];
    dateLabelsViewSmall.weekdayLabel.text = self.selectedCell.weekday;
    dateLabelsViewSmall.monthAndDayLabel.text = self.selectedCell.monthAndDay;
    [header.titleView addSubview:dateLabelsViewSmall];
    
    // Create back button for header
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button"];
    CGRect backButtonFrame = header.leftView.bounds;
//    backButtonFrame.origin.x -= 12;
    UIButton *backButton = [[UIButton alloc] initWithFrame:backButtonFrame];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [header.leftView addSubview:backButton];
    
    // Create profile button for header
    UIButton *profileButton = [[UIButton alloc] initWithFrame:header.leftView.bounds];
    [profileButton setImage:[UIImage imageNamed:@"user-profile-button"] forState:UIControlStateNormal];
    [header.leftView addSubview:profileButton];
    profileButton.alpha = 0.0;
    
    // Create active delivery button
    CGRect activeDeliveryButtonFrame = header.rightView.bounds;
    UIButton *activeDeliveryButton = [[UIButton alloc] initWithFrame:activeDeliveryButtonFrame];
    activeDeliveryButton.alpha = 0.0;
    CGFloat finalActiveDeliveryButtonAlpha;
    if ([(DaySelectViewController *)self.toViewController activeOrder]) {
        finalActiveDeliveryButtonAlpha = 1.0;
    } else {
        finalActiveDeliveryButtonAlpha = 0.5;
    }
    
    [activeDeliveryButton setImage:[UIImage imageNamed:@"map-button"] forState:UIControlStateNormal];
    [header.rightView addSubview:activeDeliveryButton];
    
    // Define snapshot frame
    CGRect selectedCellFrame = self.selectedCell.frame;
    selectedCellFrame.origin.y += (header.frame.size.height - self.contentOffset.y);
    
    // Snapshot cells above and including selected cell
    UIImageView *aboveCellsImageView = [self imageViewFromCellsAboveAndIncludingSelectedCellFrame:selectedCellFrame inViewController:self.toViewController];
    [self.containerView addSubview:aboveCellsImageView];
    
    // Snapshot cells below selected cell
    UIImageView *belowCellsImageView = [self imageViewFromCellsBelowSelectedCellFrame:selectedCellFrame inViewController:self.toViewController];
    [self.containerView addSubview:belowCellsImageView];
    [self.containerView addSubview:header];  // bring header to top
    
    // Define and set initial frames
    CATransform3D headerTitleInitialTransform = CATransform3DIdentity;
    headerTitleInitialTransform = CATransform3DTranslate(headerTitleInitialTransform, 0, - (1.5 * header.frame.size.height), 0);
    TKLogoImageView.layer.transform = headerTitleInitialTransform;

    CGPoint aboveCellsImageViewFinalCenter = aboveCellsImageView.center;
    CGPoint belowCellsImageViewFinalCenter = belowCellsImageView.center;
    aboveCellsImageView.center = CGPointMake(aboveCellsImageViewFinalCenter.x, aboveCellsImageViewFinalCenter.y - aboveCellsImageView.frame.size.height + header.frame.size.height);
    belowCellsImageView.center = CGPointMake(belowCellsImageViewFinalCenter.x, belowCellsImageViewFinalCenter.y + belowCellsImageView.frame.size.height);

    self.toViewController.view.hidden = YES;

    // Animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         TKLogoImageView.layer.transform = CATransform3DIdentity;
                         dateLabelsViewSmall.alpha = 0.0;
                         
                         aboveCellsImageView.center = aboveCellsImageViewFinalCenter;
                         belowCellsImageView.center = belowCellsImageViewFinalCenter;
                         
                         self.fromViewController.view.alpha = 0.5;
                     }
                     completion:^(BOOL finished) {
                         self.toViewController.view.hidden = NO;
                         [self.toViewController removeFromParentViewController];
                         [header removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
    [UIView animateWithDuration:duration * 0.5
                     animations:^{
                         backButton.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration * 0.5
                                          animations:^{
                                              profileButton.alpha = 1.0;
                                              activeDeliveryButton.alpha = finalActiveDeliveryButtonAlpha;
                                          } completion:^(BOOL finished) {
                                              nil;
                                          }];
                     }];
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

- (UIImageView *)imageViewFromCellsAboveAndIncludingSelectedCellFrame:(CGRect)selectedCellFrame inViewController:(UIViewController *)viewController {
    CGFloat distanceAboveSelectedCellBottomEdge = fminf(viewController.view.frame.size.height, selectedCellFrame.origin.y + selectedCellFrame.size.height);
    CGRect aboveCellsFrame = CGRectMake(0, 0, viewController.view.frame.size.width, distanceAboveSelectedCellBottomEdge);
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

- (UIImage *)snapshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageInRect:(CGRect)rect fromView:(UIView *)view {
    UIImage *viewImage = [self snapshot:view];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGImageRef image = CGImageCreateWithImageInRect(viewImage.CGImage, CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale));
    UIImage *imageInRect = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return imageInRect;
}

@end
