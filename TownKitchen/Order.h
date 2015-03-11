//
//  Order.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "User.h"

typedef enum : NSUInteger {
    TKOrderStateBeingPrepared,
    TKOrderStateOutForDelivery,
    TKOrderSTateDelivered
} TKOrderState;

@interface Order : PFObject <PFSubclassing>

//@property (strong, nonatomic) User *user;
//@property (strong, nonatomic) User *driver;
//@property (nonatomic) BOOL isReviewed;

@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSNumber *price;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *deliveryAddress;
@property (strong, nonatomic) NSDate *deliveryTime;

@property (strong, nonatomic) NSDictionary *deliveryOrigin;
@property (readonly, nonatomic) MKMapItem *deliveryOriginMapItem;

@property (strong, nonatomic) NSDictionary *driverLocation;
@property (readonly, nonatomic) MKMapItem *driverLocationMapItem;

@property (strong, nonatomic) NSDictionary *items;
@property (strong, nonatomic) NSArray *menuOptions;
@property (strong, nonatomic) NSArray *menuOptionOrders;

/* Fetch MenuOption objects from the network and populate the menuOptions
 * property. The returned BFTask completes when the menuOptions property
 * is populated, and returns the menuOptions property as its result.
 */
- (BFTask *)fetchMenuOptions;

@end
