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

@dynamic name;
@dynamic mealDescription;
@dynamic price;
@dynamic imageUrl;

+ (void)load {
    [self registerSubclass];    // this is called before application: didFinishLaunchingWithOptions:
}

+ (NSString *)parseClassName {
    return @"MenuOption";
}

@end
