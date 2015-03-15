//
//  Order.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

typedef enum : NSUInteger {
    TKOrderStateBeingPrepared,
    TKOrderStateOutForDelivery,
    TKOrderSTateDelivered
} TKOrderState;

@interface Order : PFObject <PFSubclassing>

@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSDate *deliveryDateAndTime;
@property (strong, nonatomic) NSString *deliveryAddress;
@property (strong, nonatomic) NSDictionary *items;
@property (strong, nonatomic) NSNumber *totalPrice;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) PFGeoPoint *driverLocation;

@property (readonly, nonatomic) MKMapItem *driverLocationMapItem;

@property (strong, nonatomic) NSArray *menuOptions;

/* Fetch MenuOption objects from the network and populate the menuOptions
 * property. The returned BFTask completes when the menuOptions property
 * is populated, and returns the menuOptions property as its result.
 */
- (BFTask *)fetchMenuOptions;

@end
