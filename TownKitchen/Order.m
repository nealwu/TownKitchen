//
//  Order.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "Order.h"
#import "MenuOption.h"
#import <Bolts.h>
#import <Parse/PFObject+Subclass.h>
#import "NSArray+ArrayOps.h"

@implementation Order

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Order";
}

@dynamic user;
@dynamic deliveryDateAndTime;
@dynamic deliveryAddress;
@dynamic items;
@dynamic totalPrice;
@dynamic status;
@dynamic driverLocation;

@synthesize shortNameToMenuOptionObject;
@synthesize driverLocationMapItem;

- (MKMapItem *)driverLocationMapItem {
    double latitude = self.driverLocation.latitude;
    double longitude = self.driverLocation.latitude;
    return [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil]];
}

@end
