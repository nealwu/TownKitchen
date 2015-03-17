//
//  TKOrderSummaryCell.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/8/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "TKOrderSummaryCell.h"
#import "OrderSummaryView.h"

@interface TKOrderSummaryCell ()

@property (weak, nonatomic) IBOutlet OrderSummaryView *orderSummaryView;

@end

@implementation TKOrderSummaryCell

- (void)awakeFromNib {
    // Initialization code
    [self updateSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOrder:(Order *)order {
    _order = order;
    [self updateSubviews];
}

- (void)updateSubviews {
    self.orderSummaryView.order = self.order;
}

@end
