//
//  OrderCreationTableViewCell.h
//  TownKitchen
//
//  Created by Peter Bai on 3/7/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuOption.h"
#import "MenuOptionOrder.h"

@class OrderCreationTableViewCell;

@protocol OrderCreationTableViewCellDelegate <NSObject>

- (void)orderCreationTableViewCell:(OrderCreationTableViewCell *)cell didUpdateMenuOptionOrder:(MenuOptionOrder *)menuOptionOrder;
- (void)orderCreationTableViewCellDidClearMenuOptionOrder:(OrderCreationTableViewCell *)cell;

@end

@interface OrderCreationTableViewCell : UITableViewCell

@property (strong, nonatomic) MenuOption *menuOption;
@property (weak, nonatomic) id<OrderCreationTableViewCellDelegate> delegate;

@end
