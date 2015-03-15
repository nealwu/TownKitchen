//
//  OrderCell.m
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "OrderCell.h"
#import "DateUtils.h"
#import "ParseAPI.h"

@interface OrderCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation OrderCell

@synthesize order = _order;

- (void)layoutSubviews {
    [super layoutSubviews];
    self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.frame.size.width;
}

- (void)setOrder:(Order *)order {
    _order = order;

    self.dateLabel.text = [DateUtils monthAndDayFromDate:order.deliveryDateAndTime];
    NSDictionary *items = order.items;
    NSMutableString *itemsString = [NSMutableString string];

    for (NSString *key in items) {
        NSString *description = [[ParseAPI getInstance] menuOptionForShortName:key].mealDescription;
        [itemsString appendString:description];
        [itemsString appendString:@"\n"];
    }

    self.descriptionLabel.text = itemsString;
    self.descriptionLabel.preferredMaxLayoutWidth = self.descriptionLabel.frame.size.width;
}

@end
