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

+ (BFTask *)menuOptionWithName:(NSString *)name;

@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *mealDescription;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSNumber *price;

+ (NSString *)parseClassName;

@end
