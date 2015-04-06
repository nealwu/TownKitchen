//
//  PaymentViewController.m
//  TownKitchen
//
//  Created by Peter Bai on 4/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PaymentViewController.h"
#import "SetPaymentButton.h"

@interface PaymentViewController () <PTKViewDelegate, SetPaymentButtonDelegate>

@property (weak, nonatomic) IBOutlet UIView *paymentViewPlaceholder;
@property (weak, nonatomic) IBOutlet SetPaymentButton *setPaymentButtonView;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.paymentEntryView = [[PTKView alloc] init];
    self.paymentEntryView.delegate = self;
    [self.view addSubview:self.paymentEntryView];
    
    self.setPaymentButtonView.delegate = self;
}

- (void)viewWillLayoutSubviews {
    [self.paymentViewPlaceholder setNeedsLayout];
    [self.paymentViewPlaceholder layoutIfNeeded];
    self.paymentEntryView.frame = self.paymentViewPlaceholder.frame;
}

#pragma mark - PTKViewDelegate methods

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    NSLog(@"Got payment with paymentView %@ and card %@, valid: %hhd", paymentView, card, (char)valid);
    self.valid = valid;
    [self.setPaymentButtonView setPaymentButtonValidity:valid animated:YES];
}

#pragma mark - SetPaymentButtonDelegate Methods

- (void)setPaymentButtonTapped:(SetPaymentButton *)setPaymentButton withValidity:(BOOL)validity {
    [self.delegate onSetPaymentButtonFromPaymentViewController:self withCardValidity:self.valid];
}

@end
