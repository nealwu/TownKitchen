//
//  Inventory.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Parse/Parse.h>
#import "MenuOption.h"

@interface Inventory : PFObject<PFSubclassing>

@property (strong, nonatomic) NSDate *dateOffered;
@property (strong, nonatomic) NSString *menuOptionShortName;
@property (strong, nonatomic) NSNumber *quantityRemaining;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) MenuOption *menuOptionObject;

+ (NSString *)parseClassName;

@end
