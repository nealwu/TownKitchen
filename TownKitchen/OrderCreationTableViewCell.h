//
//  OrderCreationTableViewCell.h
//  TownKitchen
//
//  Created by Peter Bai on 3/7/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuOptionOrder.h"

@class OrderCreationTableViewCell;

@protocol OrderCreationTableViewCellDelegate <NSObject>

- (void)orderCreationTableViewCell:(OrderCreationTableViewCell *)cell didUpdateMenuOptionOrder:(MenuOptionOrder *)menuOptionOrder;

@end

@interface OrderCreationTableViewCell : UITableViewCell

@property (strong, nonatomic) MenuOptionOrder *menuOptionOrder;
@property (weak, nonatomic) id<OrderCreationTableViewCellDelegate> delegate;

@end
