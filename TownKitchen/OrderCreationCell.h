//
//  OrderCreationTableViewCell.h
//  TownKitchen
//
//  Created by Peter Bai on 3/7/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuOption.h"

@class OrderCreationCell;

@protocol OrderCreationTableViewCellDelegate <NSObject>

- (void)orderCreationTableViewCell:(OrderCreationCell *)cell didUpdateQuantity:(NSNumber *)quantity;

@end

@interface OrderCreationCell : UITableViewCell

@property (strong, nonatomic) MenuOption *menuOption;
@property (strong, nonatomic) NSNumber *quantity;
@property (weak, nonatomic) id<OrderCreationTableViewCellDelegate> delegate;

@end
