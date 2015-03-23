//
//  OrderButtonView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/21/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderButtonView.h"
#import <POP.h>

@interface OrderButtonView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (assign, nonatomic) int previousQuantity;
@property (assign, nonatomic) float previousPrice;


@end

@implementation OrderButtonView

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
    UINib *nib = [UINib nibWithNibName:@"OrderButtonView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    self.quantityLabel.text = @"";
    self.priceLabel.text = @"";
    
    // create shadow
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.layer.shadowOpacity = 0.4f;
}

#pragma mark - Custom Setters

- (void)setQuantity:(int)quantity {
    self.previousQuantity = _quantity;
    _quantity = quantity;
    if (quantity == 1) {
        self.quantityLabel.text = [NSString stringWithFormat:@"%d box", quantity];
        if (self.previousQuantity == 0) {
            [self showLabels];
        }
    } else if (quantity > 1) {
        self.quantityLabel.text = [NSString stringWithFormat:@"%d boxes", quantity];
    } else if (quantity == 0){
        [self hideLabels];
    }
}

- (void)setPrice:(NSNumber *)price {
    self.previousPrice = [_price floatValue];
    _price = price;
    
    if (self.previousPrice > 0 && [price isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        return;
    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f", [price floatValue]];
    }
}

#pragma mark - Actions

- (IBAction)onOrderButton:(id)sender {
    [self.delegate orderButtonPressedFromOrderButtonView:self];
}

#pragma mark - Private Methods

- (void)showLabels {
    self.quantityLabel.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.priceLabel.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.quantityLabel.hidden = NO;
    self.priceLabel.hidden = NO;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.quantityLabel.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
    
    [UIView animateWithDuration:0.3
                          delay:0.1
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.priceLabel.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         nil;
                     }];
}

- (void)hideLabels {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.quantityLabel.transform = CGAffineTransformMakeScale(0.01, 0.01);
                     } completion:^(BOOL finished) {
                         self.quantityLabel.hidden = YES;
                     }];
    
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.priceLabel.transform = CGAffineTransformMakeScale(0.01, 0.01);
                     } completion:^(BOOL finished) {
                         self.priceLabel.hidden = YES;
                     }];
}

@end
