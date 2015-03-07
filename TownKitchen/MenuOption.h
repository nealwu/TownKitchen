//
//  MenuOption.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MenuOption : PFObject<PFSubclassing>

@property (retain) NSString *name;
@property (retain) NSString *description;
@property (retain) NSString *imageUrl;
@property (retain) NSNumber *price;

+ (NSString *)parseClassName;

@end
