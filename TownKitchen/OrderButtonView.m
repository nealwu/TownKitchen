//
//  OrderButtonView.m
//  TownKitchen
//
//  Created by Peter Bai on 3/21/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderButtonView.h"

@interface OrderButtonView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

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
    self.layer.shadowRadius = 2.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.layer.shadowOpacity = 0.4f;
}

#pragma mark - Custom Setters

- (void)setQuantity:(int)quantity {
    _quantity = quantity;
    if (quantity == 1) {
        self.quantityLabel.text = [NSString stringWithFormat:@"%d box", quantity];
    } else if (quantity > 1) {
        self.quantityLabel.text = [NSString stringWithFormat:@"%d boxes", quantity];
    } else {
        self.quantityLabel.text = @"";
    }
}

- (void)setPrice:(NSNumber *)price {
    _price = price;
    if ([price isEqualToNumber:[NSNumber numberWithInt:0]]) {
        self.priceLabel.text = @"";
    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f", [price floatValue]];
    }
}

#pragma mark - Actions

- (IBAction)onOrderButton:(id)sender {
    [self.delegate orderButtonPressedFromOrderButtonView:self];
}

@end
