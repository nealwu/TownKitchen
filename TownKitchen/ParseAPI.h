//
//  ParseAPI.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>

#import "Inventory.h"
#import "MenuOption.h"
#import "Order.h"

@interface ParseAPI : NSObject

+ (ParseAPI *)getInstance;

- (MenuOption *)menuOptionForShortName:(NSString *)shortName;
- (NSArray *)inventoryItems;
- (Inventory *)inventoryItemForShortName:(NSString *)shortName andDay:(NSDate *)date;
- (NSArray *)ordersForUser:(PFUser *)user;
- (Order *)orderBeingDeliveredForUser:(PFUser *)user;
/* Returns a task that will have an NSArray of fully-populated Order instances as its result. */
- (BFTask *)ordersForToday;
- (BOOL)validateOrder:(Order *)order;
- (BOOL)createOrder:(Order *)order;
- (BFTask *)updateOrder:(Order *)order withDriverLocation:(CLLocation *)location;
- (void)addReviewForOrder:(Order *)order starCount:(NSNumber *)stars comment:(NSString *)comment;
- (void)sendEmailConfirmationForOrder:(Order *)order;
- (void)setCurrentUserPreferredAddress:(NSString *)address withShortString:(NSString *)shortString;
- (void)setCurrentUserPreferredTime:(NSDate *)date;
- (void)setCurrentUserPaymentMethod:(NSString *)details;
- (void)forgetCurrentUserOrderPreferences;

@end
