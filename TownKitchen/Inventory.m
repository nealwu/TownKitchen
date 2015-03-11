//
//  Inventory.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "Inventory.h"

@implementation Inventory

@synthesize imageURL;
@synthesize menuOptionObject;

@dynamic dateOffered;
@dynamic menuOption;
@dynamic quantityOffered;
@dynamic quantityRemaining;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Inventory";
}

@end
