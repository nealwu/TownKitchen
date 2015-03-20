//
//  PaymentView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/19/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PaymentView.h"
#import "PTKView.h"
#import "STPCard.h"
#import "STPAPIClient.h"

@interface PaymentView () <PTKViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *paymentViewPlaceholder;
@property (strong, nonatomic) PTKView *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *setPaymentButton;

@end

@implementation PaymentView

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
    UINib *nib = [UINib nibWithNibName:@"PaymentView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    NSLog(@"sizing view frame: %@", NSStringFromCGRect(self.paymentViewPlaceholder.frame));

    self.paymentView = [[PTKView alloc] init];
    self.paymentView.delegate = self;
    [self.contentView addSubview:self.paymentView];

}

- (void)layoutSubviews {
    // layout paymentViewPlaceholder before using its frame to set the real paymentView
    [self.paymentViewPlaceholder setNeedsLayout];
    [self.paymentViewPlaceholder layoutIfNeeded];
    self.paymentView.frame = self.paymentViewPlaceholder.frame;
}

#pragma mark PTKViewDelegate methods

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    NSLog(@"Got payment with paymentView %@ and card %@", paymentView, card);
}

#pragma mark Private Methods

- (IBAction)onSetPayment:(id)sender {
     NSLog(@"sizing view frame: %@", NSStringFromCGRect(self.paymentViewPlaceholder.frame));
}

@end
