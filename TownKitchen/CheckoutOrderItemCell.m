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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark Custom Setters

- (void)setMenuOption:(MenuOption *)menuOption {
    self.nameLabel.text = menuOption.mealDescription;
    [self setup];
}

#pragma mark Private methods

- (void)setup {
    NSLog(@"%@, %@", self.quantity, self.price);
    self.quantityLabel.text = [NSString stringWithFormat:@"%@", self.quantity];
    self.priceLabel.text = [NSString stringWithFormat:@"%@", self.price];
}

@end
