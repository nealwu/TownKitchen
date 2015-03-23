//
//  RatingViewController.m
//  TownKitchen
//
//  Created by Neal Wu on 3/9/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ReviewViewController.h"

#import "ParseAPI.h"

@interface ReviewViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *oneStarView;
@property (weak, nonatomic) IBOutlet UIImageView *twoStarView;
@property (weak, nonatomic) IBOutlet UIImageView *threeStarView;
@property (weak, nonatomic) IBOutlet UIImageView *fourStarView;
@property (weak, nonatomic) IBOutlet UIImageView *fiveStarView;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (assign, nonatomic) NSInteger ratingStars;

@end

@implementation ReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Review";
    self.commentView.delegate = self;
    self.commentView.textColor = [UIColor grayColor];
    self.commentView.layer.borderWidth = 1;
    self.commentView.layer.cornerRadius = 5;
    self.submitButton.hidden = YES;
    self.ratingStars = 0;
}

- (IBAction)onOneStarTap:(id)sender {
    NSLog(@"One star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-on"];
    self.twoStarView.image = [UIImage imageNamed:@"star-off"];
    self.threeStarView.image = [UIImage imageNamed:@"star-off"];
    self.fourStarView.image = [UIImage imageNamed:@"star-off"];
    self.fiveStarView.image = [UIImage imageNamed:@"star-off"];
    self.submitButton.hidden = NO;
    self.ratingStars = 1;
}

- (IBAction)onTwoStarTap:(id)sender {
    NSLog(@"Two star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-on"];
    self.twoStarView.image = [UIImage imageNamed:@"star-on"];
    self.threeStarView.image = [UIImage imageNamed:@"star-off"];
    self.fourStarView.image = [UIImage imageNamed:@"star-off"];
    self.fiveStarView.image = [UIImage imageNamed:@"star-off"];
    self.submitButton.hidden = NO;
    self.ratingStars = 2;

}

- (IBAction)onThreeStarTap:(id)sender {
    NSLog(@"Three star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-on"];
    self.twoStarView.image = [UIImage imageNamed:@"star-on"];
    self.threeStarView.image = [UIImage imageNamed:@"star-on"];
    self.fourStarView.image = [UIImage imageNamed:@"star-off"];
    self.fiveStarView.image = [UIImage imageNamed:@"star-off"];
    self.submitButton.hidden = NO;
    self.ratingStars = 3;
}

- (IBAction)onFourStarTap:(id)sender {
    NSLog(@"Four star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-on"];
    self.twoStarView.image = [UIImage imageNamed:@"star-on"];
    self.threeStarView.image = [UIImage imageNamed:@"star-on"];
    self.fourStarView.image = [UIImage imageNamed:@"star-on"];
    self.fiveStarView.image = [UIImage imageNamed:@"star-off"];
    self.submitButton.hidden = NO;
    self.ratingStars = 4;
}

- (IBAction)onFiveStarTap:(id)sender {
    NSLog(@"Five star tap");
    self.oneStarView.image = [UIImage imageNamed:@"star-on"];
    self.twoStarView.image = [UIImage imageNamed:@"star-on"];
    self.threeStarView.image = [UIImage imageNamed:@"star-on"];
    self.fourStarView.image = [UIImage imageNamed:@"star-on"];
    self.fiveStarView.image = [UIImage imageNamed:@"star-on"];
    self.submitButton.hidden = NO;
    self.ratingStars = 5;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqual:@"Leave a review (optional)"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"Leave a review (optional)";
        textView.textColor = [UIColor grayColor];
    }

    return YES;
}

- (IBAction)onGeneralTap:(id)sender {
    [self.commentView endEditing:YES];
}

- (IBAction)onSubmit:(id)sender {
    [[ParseAPI getInstance] addReviewForOrder:self.order starCount:@(self.ratingStars) comment:self.commentView.text];
    NSLog(@"Submitted with %ld star(s) and comment %@", (long) self.ratingStars, self.commentView.text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
