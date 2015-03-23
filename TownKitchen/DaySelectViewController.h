//
//  DaySelectViewController.h
//  TownKitchen
//
//  Created by Neal Wu on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface DaySelectViewController : UIViewController

@property (readonly, nonatomic) Order *activeOrder;

@end
