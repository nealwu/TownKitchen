//
//  RatingViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/9/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ReviewViewController.h"

#import "DateUtils.h"
#import "OrderSummaryView.h"
#import "ParseAPI.h"
#import "ReviewLabelsView.h"
#import "TKHeader.h"
#import <POP.h>

@interface ReviewViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *oneStarView;
@property (weak, nonatomic) IBOutlet UIImageView *twoStarView;
@property (weak, nonatomic) IBOutlet UIImageView *threeStarView;
@property (weak, nonatomic) IBOutlet UIImageView *fourStarView;
@property (weak, nonatomic) IBOutlet UIImageView *fiveStarView;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet OrderSummaryView *orderSummaryView;
@property (weak, nonatomic) IBOutlet TKHeader *header;

@property (assign, nonatomic) NSInteger ratingStars;

@end

@implementation ReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set up header
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.header.titleView.bounds];
    titleLabel.text = @"Review Your Order";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Futura" size:20];
    
    ReviewLabelsView *titleView = [[ReviewLabelsView alloc] initWithFrame:self.header.titleView.bounds];
    titleView.dateLabel.text = [NSString stringWithFormat:@"%@, %@", [DateUtils dayOfTheWeekFromDate:self.order.deliveryTimeUtc], [DateUtils monthAndDayFromDate:self.order.deliveryTimeUtc]];
    [self.header.titleView addSubview:titleView];

    UIButton *cancelButton = [[UIButton alloc] initWithFrame:self.header.leftView.bounds];
    [cancelButton addTarget:self action:@selector(onCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"cancel-button"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"cancel-button-highlighted"] forState:UIControlStateHighlighted];
    [self.header.leftView addSubview:cancelButton];

    self.orderSummaryView.order = self.order;
    
    self.commentView.delegate = self;
    self.commentView.textColor = [UIColor grayColor];
    self.commentView.layer.cornerRadius = 8;
    [self.commentView setTextContainerInset:UIEdgeInsetsMake(8, 8, 8, 8)];

    self.submitButton.layer.opacity = 0;
    self.submitButton.enabled = NO;
    self.ratingStars = 0;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqual:@"Leave a comment (optional)"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"Leave a comment (optional)";
        textView.textColor = [UIColor grayColor];
    }

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

#pragma mark - Actions

- (IBAction)onOneStarTap:(id)sender {
    NSLog(@"One star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-selected"];
    self.twoStarView.image = [UIImage imageNamed:@"star"];
    self.threeStarView.image = [UIImage imageNamed:@"star"];
    self.fourStarView.image = [UIImage imageNamed:@"star"];
    self.fiveStarView.image = [UIImage imageNamed:@"star"];
    self.ratingStars = 1;
    [self animateCommentBoxAndSubmitButton];
}

- (IBAction)onTwoStarTap:(id)sender {
    NSLog(@"Two star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-selected"];
    self.twoStarView.image = [UIImage imageNamed:@"star-selected"];
    self.threeStarView.image = [UIImage imageNamed:@"star"];
    self.fourStarView.image = [UIImage imageNamed:@"star"];
    self.fiveStarView.image = [UIImage imageNamed:@"star"];
    self.ratingStars = 2;
    [self animateCommentBoxAndSubmitButton];
}

- (IBAction)onThreeStarTap:(id)sender {
    NSLog(@"Three star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-selected"];
    self.twoStarView.image = [UIImage imageNamed:@"star-selected"];
    self.threeStarView.image = [UIImage imageNamed:@"star-selected"];
    self.fourStarView.image = [UIImage imageNamed:@"star"];
    self.fiveStarView.image = [UIImage imageNamed:@"star"];
    self.ratingStars = 3;
    [self animateCommentBoxAndSubmitButton];
}

- (IBAction)onFourStarTap:(id)sender {
    NSLog(@"Four star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-selected"];
    self.twoStarView.image = [UIImage imageNamed:@"star-selected"];
    self.threeStarView.image = [UIImage imageNamed:@"star-selected"];
    self.fourStarView.image = [UIImage imageNamed:@"star-selected"];
    self.fiveStarView.image = [UIImage imageNamed:@"star"];
    self.ratingStars = 4;
    [self animateCommentBoxAndSubmitButton];
}

- (IBAction)onFiveStarTap:(id)sender {
    NSLog(@"Five star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-selected"];
    self.twoStarView.image = [UIImage imageNamed:@"star-selected"];
    self.threeStarView.image = [UIImage imageNamed:@"star-selected"];
    self.fourStarView.image = [UIImage imageNamed:@"star-selected"];
    self.fiveStarView.image = [UIImage imageNamed:@"star-selected"];
    self.ratingStars = 5;
    [self animateCommentBoxAndSubmitButton];
}

- (IBAction)onGeneralTap:(id)sender {
    [self.commentView endEditing:YES];
}

- (IBAction)onSubmit:(id)sender {
    [[ParseAPI getInstance] addReviewForOrder:self.order starCount:@(self.ratingStars) comment:self.commentView.text];
    NSLog(@"Submitted with %ld star(s) and comment %@", (long) self.ratingStars, self.commentView.text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)onCancelButton {
    self.order.status = @"review_declined";
    [self.order save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)animateCommentBoxAndSubmitButton {
    if (self.submitButton.enabled) {
        return;
    }
    self.submitButton.enabled = YES;
    
    POPBasicAnimation *scaleSmallAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleSmallAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.1f, 0.1f)];
    scaleSmallAnimation.duration = 0.0;
    
    POPSpringAnimation *scaleSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleSpringAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(8.f, 8.f)];
    scaleSpringAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleSpringAnimation.springBounciness = 12.0f;
    
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(1.0);
    opacityAnimation.duration = 0.5;
    
    [scaleSmallAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        [self.submitButton.layer pop_addAnimation:scaleSpringAnimation forKey:@"layerScaleSpringAnimation"];
    }];
    [self.submitButton.layer pop_addAnimation:scaleSmallAnimation forKey:@"layerScaleSmallAnimation"];
    [self.submitButton.layer pop_addAnimation:opacityAnimation forKey:@"layerFullOpacityAnimation"];
}

@end
