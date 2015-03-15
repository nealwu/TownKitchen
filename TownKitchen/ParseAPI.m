//
//  ParseAPI.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ParseAPI.h"

#import "DateUtils.h"
#import "Inventory.h"
#import "MenuOption.h"
#import "Order.h"

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
    NSDictionary *items = order.items;

    for (NSString *shortName in items) {
        Inventory *inventory = [self inventoryItemForShortName:shortName andDay:order.deliveryDateAndTime];

        if ([items[shortName] integerValue] > [inventory.quantityRemaining integerValue]) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)createOrder:(Order *)order {
    if ([order save]) {
        NSDictionary *items = order.items;

        for (NSString *shortName in items) {
            Inventory *inventory = [self inventoryItemForShortName:shortName andDay:order.deliveryDateAndTime];
            inventory.quantityRemaining = @([inventory.quantityRemaining integerValue] - [items[shortName] integerValue]);
            [inventory save];
        }

        return YES;
    }

    return NO;
}

- (void)addReviewForOrder:(Order *)order starCount:(NSNumber *)stars comment:(NSString *)comment {
    PFObject *review = [PFObject objectWithClassName:@"Review"];
    review[@"comments"] = comment;
    review[@"order"] = order;
    review[@"starRating"] = stars;
    [review save];
}

@end
