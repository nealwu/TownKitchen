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

- (void)setMenuOptionOrder:(MenuOptionOrder *)menuOptionOrder {
    _menuOptionOrder = menuOptionOrder;
    self.quantityLabel.text = [NSString stringWithFormat:@"%@", menuOptionOrder.quantity];
    self.nameLabel.text = menuOptionOrder.menuOption.name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@", menuOptionOrder.totalPrice];
}


@end
