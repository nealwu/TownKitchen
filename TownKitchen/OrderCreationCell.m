//
//  OrderCreationTableViewCell.m
//  TownKitchen
//
//  Created by Peter Bai on 3/7/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCreationCell.h"
#import "CircleStepperView.h"

#import <UIImageView+AFNetworking.h>


@interface OrderCreationCell () <CircleStepperViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mealImage;
@property (weak, nonatomic) IBOutlet UILabel *mealDescription;
@property (weak, nonatomic) IBOutlet CircleStepperView *circleStepperView;

@end

@implementation OrderCreationCell

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

- (void)setMenuOption:(MenuOption *)menuOption {
    _menuOption = menuOption;
    self.mealDescription.text = menuOption.mealDescription;
    [self.mealImage setImageWithURL:[NSURL URLWithString:menuOption.imageURL]];
}

- (void)setQuantity:(NSNumber *)quantity {
    self.circleStepperView.value = [quantity integerValue];
}

#pragma mark Private Methods

- (void)setup{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.circleStepperView.delegate = self;
}

#pragma mark CircleStepperViewDelegate Methods

- (void)circleStepperView:(CircleStepperView *)circleStepperView didUpdateValue:(int)value {
    NSNumber *numberValue = [NSNumber numberWithInt:value];
    [self.delegate orderCreationTableViewCell:self didUpdateQuantity:numberValue];
}

@end
