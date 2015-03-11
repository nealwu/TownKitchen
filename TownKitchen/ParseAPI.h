//
//  ParseAPI.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>
#import "Order.h"
#import "MenuOption.h"

@interface ParseAPI : NSObject

+ (ParseAPI *)getInstance;

- (NSArray *)dayInventories;
- (NSArray *)ordersForUser:(NSString *)username;
- (PFGeoPoint *)locationForOrder:(Order *)order;
- (NSString *)imageURLForMenuOption:(NSString *)menuOption;
- (MenuOption *)menuOptionForName:(NSString *)name;

- (void)createOrder:(Order *)order;
- (void)addReviewForOrder:(Order *)order starCount:(NSNumber *)stars comment:(NSString *)comment;
- (void)setDeliveryLocationForOrder:(Order *)order location:(PFGeoPoint *)location;

@end
