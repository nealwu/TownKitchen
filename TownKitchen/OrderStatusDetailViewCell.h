//
//  OrderStatusDetailViewCell.h
//  TownKitchen
//
//  Created by Peter Bai on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderStatusDetailViewCell : UITableViewCell

@property (strong, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSString *imageUrl;

@end
