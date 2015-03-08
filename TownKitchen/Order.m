//
//  Order.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "Order.h"
#import <Parse/PFObject+Subclass.h>

@implementation Order

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Order";
}

@dynamic deliveryAddress;
@dynamic deliveryOrigin;

- (MKMapItem *)deliveryOriginMapItem {
    NSNumber *latitude = self.deliveryOrigin[@"latitude"];
    NSNumber *longitude = self.deliveryOrigin[@"longitude"];
    return [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue) addressDictionary:nil]];
}

@dynamic driverLocation;

- (MKMapItem *)driverLocationMapItem {
    NSNumber *latitude = self.driverLocation[@"latitude"];
    NSNumber *longitude = self.driverLocation[@"longitude"];
    return [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue) addressDictionary:nil]];
}

@end
