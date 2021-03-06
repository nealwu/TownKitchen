//
//  ParseAPI.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Bolts.h>
#import "ParseAPI.h"
#import "Order.h"
#import "NSArray+ArrayOps.h"

#import "DateUtils.h"
#import "Inventory.h"
#import "MenuOption.h"
#import "Order.h"

#include <AudioToolbox/AudioToolbox.h>

@implementation ParseAPI

+ (ParseAPI *)getInstance {
    static ParseAPI *instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[ParseAPI alloc] init];
        }
    });

    return instance;
}

- (MenuOption *)menuOptionForShortName:(NSString *)shortName {
    PFQuery *query = [PFQuery queryWithClassName:@"MenuOption"];
    [query whereKey:@"shortName" equalTo:shortName];
    query.cachePolicy = 3;
    NSArray *menuOptions = [query findObjects];

    if (menuOptions.count == 0) {
        NSLog(@"Could not find any menu options with short name %@", shortName);
        return nil;
    }

    return menuOptions[0];
}

- (NSArray *)inventoryItems {
    PFQuery *query = [PFQuery queryWithClassName:@"Inventory"];
    [query whereKey:@"dateOffered" greaterThanOrEqualTo:[NSDate date]];
    NSArray *items = [query findObjects];

    // Populate the menuOptionObject field
    for (Inventory *inventory in items) {
        inventory.menuOptionObject = [self menuOptionForShortName:inventory.menuOptionShortName];
    }

    return items;
}

- (Inventory *)inventoryItemForShortName:(NSString *)shortName andDay:(NSDate *)date {
    PFQuery *query = [PFQuery queryWithClassName:@"Inventory"];
    [query whereKey:@"menuOptionShortName" equalTo:shortName];
    [query whereKey:@"dateOffered" greaterThanOrEqualTo:[DateUtils beginningOfDay:date]];
    [query whereKey:@"dateOffered" lessThan:[DateUtils endOfDay:date]];
    NSArray *items = [query findObjects];

    for (Inventory *inventory in items) {
        if ([DateUtils compareDayFromDate:inventory.dateOffered withDate:date]) {
            MenuOption *menuOption = [self menuOptionForShortName:[inventory menuOptionShortName]];

            if ([menuOption.shortName isEqualToString:shortName]) {
                inventory.menuOptionObject = [self menuOptionForShortName:inventory.menuOptionShortName];
                return inventory;
            }
        }
    }

    return nil;
}

- (NSArray *)ordersForUser:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:@"Order"];
    [query whereKey:@"user" equalTo:user];
    NSArray *orders = [query findObjects];
    return orders;
}

- (BOOL)validateOrder:(Order *)order {
    if (!order || order.items.count < 1) {
        return NO;
    }
    NSDictionary *items = order.items;

    for (NSString *shortName in items) {
        Inventory *inventory = [self inventoryItemForShortName:shortName andDay:order.deliveryDateAndTime];

        if ([items[shortName] integerValue] > [inventory.quantityRemaining integerValue]) {
            NSLog(@"Inventory for %@ is not enough for order: %@ vs. %@", inventory.menuOptionObject.shortName, items[shortName], inventory.quantityRemaining);
            return NO;
        }
    }

    return YES;
}

- (Order *)orderBeingDeliveredForUser:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:@"Order"];
    [query whereKey:@"user" equalTo:user];
    [query whereKey:@"status" equalTo:@"delivering"];
    [query orderByAscending:@"deliveryDateAndTime"];
    NSArray *orders = [query findObjects];
    return orders.firstObject;
}

- (BOOL)createOrder:(Order *)order {
    if ([order save]) {
        NSLog(@"Successfully saved order");
        NSDictionary *items = order.items;

        for (NSString *shortName in items) {
            Inventory *inventory = [self inventoryItemForShortName:shortName andDay:order.deliveryDateAndTime];
            inventory.quantityRemaining = @([inventory.quantityRemaining integerValue] - [items[shortName] integerValue]);
            [inventory save];
        }

        return YES;
    } else {
        NSLog(@"Error saving order");
    }

    return NO;
}

- (BFTask *)updateOrder:(Order *)order withDriverLocation:(CLLocation *)location {
    PFGeoPoint *newLocation = [PFGeoPoint geoPointWithLocation:location];
    order.status = @"delivering";
    order.driverLocation = newLocation;
    return [order saveInBackground];
}

- (void)addReviewForOrder:(Order *)order starCount:(NSNumber *)stars comment:(NSString *)comment {
    PFObject *review = [PFObject objectWithClassName:@"Review"];
    review[@"comments"] = comment;
    review[@"order"] = order;
    review[@"starRating"] = stars;
    [review save];

    order.status = @"reviewed";
    [order save];
}

- (BFTask *)ordersForToday {
    NSDate *now = [NSDate date];
    NSCalendar *localCalendar = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [localCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:now];
    NSCalendar *utcCalendar = [NSCalendar currentCalendar];
    utcCalendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    /* create dates for querying as if they were representing UTC, since display in Parse's web UI is in UTC */
    NSDate *previousMidnight = [utcCalendar dateFromComponents:nowComponents];
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    oneDay.day = 1;
    NSDate *nextMidnight = [utcCalendar dateByAddingComponents:oneDay toDate:previousMidnight options:0];
    NSLog(@"range from: %@ to %@", previousMidnight, nextMidnight);

    PFQuery *query = [Order query];
    [query whereKey:@"deliveryDateAndTime" greaterThanOrEqualTo:previousMidnight];
//    [query whereKey:@"deliveryDateAndTime" lessThan:nextMidnight];
    
    return [query findObjectsInBackground];
}

- (void)sendEmailConfirmationForOrder:(Order *)order {
    [PFCloud callFunctionInBackground:@"sendConfirmationMail"
                       withParameters:@{@"email": order.user.email,
                                        @"items": order.items,
                                        @"deliveryDateAndTime": order.deliveryDateAndTime,
                                        @"totalPrice": order.totalPrice}
                                block:^(id object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"sendConfirmationMail successful. Response: %@", object);
                                    } else {
                                        NSLog(@"%@", error);
                                    }
                                }];
}

- (void)setCurrentUserPreferredAddress:(NSString *)address withShortString:(NSString *)shortString {
    [[PFUser currentUser] setValue:address forKey:@"preferredAddress"];
    [[PFUser currentUser] setValue:shortString forKey:@"preferredAddressShort"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully saved preferred address");
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)setCurrentUserPreferredTime:(NSDate *)date {
    [[PFUser currentUser] setValue:date forKey:@"preferredTime"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully saved preferred time");
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)setCurrentUserPaymentMethod:(NSString *)details {
    // do not store actual card info on server
    [[PFUser currentUser] setValue:details forKey:@"paymentMethod"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully saved payment method");
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)forgetCurrentUserOrderPreferences {
    [[PFUser currentUser] removeObjectForKey:@"preferredAddress"];
    [[PFUser currentUser] removeObjectForKey:@"preferredAddressShort"];
    [[PFUser currentUser] removeObjectForKey:@"preferredTime"];
    [[PFUser currentUser] removeObjectForKey:@"paymentMethod"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully cleared order preferences");
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)simulateDeliveryForCurrentUser {
    [self vibrate];
    [PFCloud callFunctionInBackground:@"simulateDelivery"
                       withParameters:@{}
                                block:^(id object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Request to simulate delivery successful. Response: %@", object);
                                        [self vibrate];
                                        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(vibrate) userInfo:nil repeats:NO];
                                    } else {
                                        NSLog(@"%@", error);
                                    }
                                }];
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
