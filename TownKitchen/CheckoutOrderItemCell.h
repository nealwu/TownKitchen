//
//  CheckoutOrderItemCell.h
//  TownKitchen
//
//  Created by Peter Bai on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuOption.h"

@interface CheckoutOrderItemCell : UITableViewCell

@property (strong, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *price;
@property (weak, nonatomic) IBOutlet UILabel *menuOptionImage;

@end
