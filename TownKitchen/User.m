//
//  User.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "User.h"

@implementation User

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"User";
}

@dynamic username;
@dynamic createdAt;

@end
