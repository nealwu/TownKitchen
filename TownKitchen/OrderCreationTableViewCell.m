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

@property (strong, nonatomic) NSNumber *orderQuantity;

@end

@implementation OrderCreationTableViewCell

- (void)awakeFromNib {
    [self setup];
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

- (void)setMenuOptionOrder:(MenuOptionOrder *)menuOptionOrder {
    _menuOptionOrder = menuOptionOrder;
    self.mealDescription.text = menuOptionOrder.menuOption.mealDescription;
    [self.mealImage setImageWithURL:[NSURL URLWithString:menuOptionOrder.menuOption.imageUrl]];
    self.orderQuantityLabel.text = [NSString stringWithFormat:@"%@", self.menuOptionOrder.quantity];
}

#pragma mark Private Methods

- (void)setup{
    self.menuOptionOrder = [[MenuOptionOrder alloc] init];
}

#pragma mark Actions

- (IBAction)onStepperChanged:(UIStepper *)stepper {
    NSNumber *value = [NSNumber numberWithDouble:stepper.value];
    self.orderQuantity = value;
    self.orderQuantityLabel.text = [NSString stringWithFormat:@"%@", value];
    self.menuOptionOrder.quantity = value;
    [self.delegate orderCreationTableViewCell:self didUpdateMenuOptionOrder:self.menuOptionOrder];
}

@end
