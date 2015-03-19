//
//  CheckoutOrderItemCell.m
//  TownKitchen
//
//  Created by Peter Bai on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "CheckoutOrderItemCell.h"

@interface CheckoutOrderItemCell ()

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation CheckoutOrderItemCell

#pragma mark Custom Setters

- (void)setItemDescription:(NSString *)itemDescription {
    _itemDescription = itemDescription;
    self.nameLabel.text = itemDescription;
}

- (void)setQuantity:(NSNumber *)quantity {
    _quantity = quantity;

    if ([quantity doubleValue] > 0) {
        self.quantityLabel.text = [NSString stringWithFormat:@"%.0f", [quantity floatValue]];
    } else {
        self.quantityLabel.text = @"";
    }
}

- (void)setPrice:(NSNumber *)price {
    _price = price;
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f", [price floatValue]];
}

@end
