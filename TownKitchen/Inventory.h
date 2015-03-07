//
//  Inventory.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Parse/Parse.h>
#import "MenuOption.h"

@interface Inventory : PFObject

@property (strong, nonatomic) MenuOption *menuOption;
@property (strong, nonatomic) NSNumber *quantityOffered;
@property (strong, nonatomic) NSNumber *quantityRemaining;

@end
