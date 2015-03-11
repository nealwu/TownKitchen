//
//  ParseAPI.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "ParseAPI.h"
#import "User.h"
#import "Order.h"
#import "MenuOption.h"

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

- (NSArray *)dayInventories {
    PFQuery *query = [PFQuery queryWithClassName:@"Inventory"];

    NSArray *inventories = [query findObjects];
    //    NSLog(@"DI returned %ld inventories", inventories.count);
    //    NSLog(@"Inventories: %@", inventories);
    //    PFObject *inventory = inventories[0];
    //    NSLog(@"Object ID: %@", inventory.objectId);
    //    NSLog(@"Date offered: %@", inventory[@"dateOffered"]);
    //    NSLog(@"Keys: %@", [inventory allKeys]);
    return inventories;
}

- (NSArray *)ordersForUser:(NSString *)username {
    PFQuery *query = [PFQuery queryWithClassName:@"Order"];
    [query whereKey:@"username" equalTo:username];
    NSArray *orders = [query findObjects];
    return orders;
}

- (PFGeoPoint *)locationForOrder:(Order *)order {
    return [PFGeoPoint geoPointWithLatitude:[order.driverLocation[@"latitude"] doubleValue] longitude:[order.driverLocation[@"longitude"] doubleValue]];
//    return order.deliveryLocation;
    //    NSDictionary *deliveryLocation = order.deliveryLocation;
    //    double latitude = [deliveryLocation[@"latitude"] doubleValue];
    //    double longitude = [deliveryLocation[@"longitude"] doubleValue];
    //    return [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
}

- (NSString *)imageURLForMenuOption:(NSString *)menuOption {
    PFQuery *query = [PFQuery queryWithClassName:@"MenuOption"];
    [query whereKey:@"name" equalTo:menuOption];
    NSArray *menuOptions = [query findObjects];

    if (menuOptions.count == 0) {
        return nil;
    }

    return ((MenuOption *) menuOptions[0]).imageUrl;
}

- (MenuOption *)menuOptionForName:(NSString *)name {
    PFQuery *query = [PFQuery queryWithClassName:@"MenuOption"];
    [query whereKey:@"name" equalTo:name];
    NSArray *menuOptions = [query findObjects];

    if (menuOptions.count == 0) {
        return nil;
    }

    return menuOptions[0];
}

- (void)createOrder:(Order *)order {
    //    PFObject *orderObj = [PFObject objectWithClassName:@"Order"];
    //    orderObj[@"deliveryAddress"] = order.deliveryAddress;
    //    orderObj[@"deliveryOrigin"] = order.deliveryOrigin;
    //    orderObj[@"driverLocation"] = order.driverLocation;
    //    orderObj[@"items"] = order.items;
    // TODO: fill in the rest of the fields
    [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Order save succeeded");
        } else {
            NSLog(@"Order save failed: %@", error);
        }
    }];
}

- (void)addReviewForOrder:(Order *)order starCount:(NSNumber *)stars comment:(NSString *)comment {
    PFObject *review = [PFObject objectWithClassName:@"Review"];
    review[@"comments"] = comment;
    review[@"order"] = [PFObject objectWithoutDataWithClassName:@"Order" objectId:order.objectId];
    review[@"starRating"] = stars;
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Review saved successfully!");
        } else {
            NSLog(@"Review saving failed: %@", error);
        }
    }];
}

- (void)setDeliveryLocationForOrder:(Order *)order location:(PFGeoPoint *)location {

}

@end
