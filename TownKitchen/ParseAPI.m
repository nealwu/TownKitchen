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

@implementation ParseAPI

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

- (NSArray *)ordersForUser:(User *)user {
        PFQuery *query = [PFQuery queryWithClassName:@"Order"];
        [query whereKey:@"username" equalTo:user.username];
        NSArray *orders = [query findObjects];
        return orders;
    }

- (PFGeoPoint *)locationForOrder:(Order *)order {
        return order.deliveryLocation;
    //    NSDictionary *deliveryLocation = order.deliveryLocation;
    //    double latitude = [deliveryLocation[@"latitude"] doubleValue];
    //    double longitude = [deliveryLocation[@"longitude"] doubleValue];
    //    return [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
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
        PFObject *review = [PFObject objectWithClassName:@"Reviews"];
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
