//
//  Inventory.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "Inventory.h"

@implementation Inventory

@dynamic menuOptionShortName;
@dynamic dateOffered;
@dynamic quantityRemaining;

@synthesize imageURL;
@synthesize menuOptionObject;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Inventory";
}

@end
