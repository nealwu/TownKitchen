//
//  MenuOptionOrder.h
//  TownKitchen
//
//  Created by Peter Bai on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuOption.h"

@interface MenuOptionOrder : NSObject

@property (strong, nonatomic) MenuOption *menuOption;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *totalPrice;

@end
