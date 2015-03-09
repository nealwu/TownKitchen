//
//  TKMenuOptionCell.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "TKMenuOptionCell.h"

@interface TKMenuOptionCell ()

@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *menuOptionLabel;

@end

@implementation TKMenuOptionCell

- (void)awakeFromNib {
    // Initialization code
    [self updateSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateSubviews {
    self.quantityLabel.text = [NSString stringWithFormat:@"%ldx", (long)self.quantity];
    self.menuOptionLabel.text = self.menuOption.mealDescription;
}

- (void)setQuantity:(NSInteger)quantity {
    _quantity = quantity;
    [self updateSubviews];
}

- (void)setMenuOption:(MenuOption *)menuOption {
    _menuOption = menuOption;
    [self updateSubviews];
}

@end
