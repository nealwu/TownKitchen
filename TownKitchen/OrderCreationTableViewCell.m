//
//  OrderCreationTableViewCell.m
//  TownKitchen
//
//  Created by Peter Bai on 3/7/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCreationTableViewCell.h"
#import <UIImageView+AFNetworking.h>

@interface OrderCreationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mealImage;
@property (weak, nonatomic) IBOutlet UILabel *mealDescription;
@property (weak, nonatomic) IBOutlet UILabel *orderQuantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *orderStepper;

@end

@implementation OrderCreationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mealDescription.preferredMaxLayoutWidth = self.mealDescription.frame.size.width;
}

#pragma mark Custom Setters

- (void)setMenuOption:(MenuOption *)menuOption {
    _menuOption = menuOption;
    self.mealDescription.text = menuOption.mealDescription;
    [self.mealImage setImageWithURL:[NSURL URLWithString:menuOption.imageUrl]];
    self.orderQuantityLabel.text = @"0";
}

#pragma mark Actions

- (IBAction)onStepperChanged:(UIStepper *)stepper {
    NSNumber *value = [NSNumber numberWithDouble:stepper.value];
    self.orderQuantity = value;
    self.orderQuantityLabel.text = [NSString stringWithFormat:@"%@", value];
}



@end
