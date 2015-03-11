//
//  MenuOption.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "MenuOption.h"
#import <Parse/PFObject+Subclass.h>

@implementation MenuOption

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"MenuOption";
}

+ (MenuOption *)menuOptionWithName:(NSString *)name {
    PFQuery *query = [self query];
    [query whereKey:@"name" equalTo:name];
    return (MenuOption *) [query getFirstObject];
}

@dynamic name;
@dynamic mealDescription;
@dynamic price;
@dynamic imageUrl;

@end
