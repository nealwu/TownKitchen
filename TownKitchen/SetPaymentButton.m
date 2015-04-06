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
    CGFloat yPositionChange = self.contentView.frame.size.height;
    CGAffineTransform yPositionShiftTransform = CGAffineTransformMakeTranslation(0, -yPositionChange);

    self.backButton.transform = yPositionShiftTransform;
    self.saveButton.transform =yPositionShiftTransform;
    self.backgroundViewValid.alpha = 1.0;
    NSLog(@"setting button to valid");
}

- (void)setButtonToInvalidState {
    self.backButton.transform = CGAffineTransformIdentity;
    self.saveButton.transform = CGAffineTransformIdentity;
    self.backgroundViewValid.alpha = 0.0;
    NSLog(@"setting button to in-valid");
}

- (void)animateButtonToValidState {
    CGFloat yPositionChange = self.contentView.frame.size.height;
    CGAffineTransform yPositionShiftTransform = CGAffineTransformMakeTranslation(0, -yPositionChange);
    
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backButton.transform = yPositionShiftTransform;
                         self.saveButton.transform = yPositionShiftTransform;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundViewValid.alpha = 1.0;
    }];
}

- (void)animateButtonToInvalidState {
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backButton.transform = CGAffineTransformIdentity;
                         self.saveButton.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundViewValid.alpha = 0.0;
    }];
}

@end
