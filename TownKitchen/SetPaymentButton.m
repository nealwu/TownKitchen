//
//  SetPaymentButton.m
//  TownKitchen
//
//  Created by Peter Bai on 4/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "SetPaymentButton.h"

@interface SetPaymentButton ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundViewValid;

@end

@implementation SetPaymentButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    // Load nib
    UINib *nib = [UINib nibWithNibName:@"SetPaymentButton" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

- (void)setPaymentButtonValidity:(BOOL)valid {
    [self setPaymentButtonValidity:valid animated:NO];
}

- (void)setPaymentButtonValidity:(BOOL)valid animated:(BOOL)animated {
    if (animated) {
        if (valid) {
            [self animateButtonToValidState];
        } else {
            [self animateButtonToInvalidState];
        }
        
    } else {
        if (valid) {
            [self setButtonToValidState];
        } else {
            [self setButtonToInvalidState];
        }
    }
}

#pragma mark - Actions

- (IBAction)onBackButton:(id)sender {
    [self.delegate setPaymentButtonTapped:self withValidity:NO];
}

- (IBAction)onSaveButton:(id)sender {
    [self.delegate setPaymentButtonTapped:self withValidity:YES];
}

#pragma mark - Private Methods

- (void)setButtonToValidState {    
    CGFloat heightChange = self.contentView.frame.size.height;
    CGRect finalBackButtonFrame = self.contentView.frame;
    finalBackButtonFrame.origin.y -= heightChange;
    CGRect finalSaveButtonFrame = self.contentView.frame;
    
    self.backButton.frame = finalBackButtonFrame;
    self.saveButton.frame = finalSaveButtonFrame;
    self.backgroundViewValid.alpha = 1.0;
    NSLog(@"setting button to valid");
}

- (void)setButtonToInvalidState {
    CGFloat heightChange = self.contentView.frame.size.height;
    CGRect finalBackButtonFrame = self.contentView.frame;
    CGRect finalSaveButtonFrame = self.contentView.frame;
    finalSaveButtonFrame.origin.y += heightChange;
    
    self.backButton.frame = finalBackButtonFrame;
    self.saveButton.frame = finalSaveButtonFrame;
    self.backgroundViewValid.alpha = 0.0;
    NSLog(@"setting button to in-valid");
}

- (void)animateButtonToValidState {
    CGFloat heightChange = self.contentView.frame.size.height;
    CGRect finalBackButtonFrame = self.contentView.frame;
    finalBackButtonFrame.origin.y -= heightChange;
    CGRect finalSaveButtonFrame = self.contentView.frame;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backButton.frame = finalBackButtonFrame;
                         self.saveButton.frame = finalSaveButtonFrame;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundViewValid.alpha = 1.0;
    }];
}

- (void)animateButtonToInvalidState {
    CGFloat heightChange = self.contentView.frame.size.height;
    CGRect finalBackButtonFrame = self.contentView.frame;
    CGRect finalSaveButtonFrame = self.contentView.frame;
    finalSaveButtonFrame.origin.y += heightChange;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backButton.frame = finalBackButtonFrame;
                         self.saveButton.frame = finalSaveButtonFrame;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundViewValid.alpha = 0.0;
    }];
}

@end
