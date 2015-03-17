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
#import "ParseAPI.h"
#import "NSArray+ArrayOps.h"

@interface Order ()

@end

@implementation Order

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Order";
}

@dynamic user;
@dynamic deliveryDateAndTime;

@synthesize deliveryTimeUtc = _deliveryTimeUtc;

- (NSDate *)deliveryTimeUtc {
    if (!_deliveryTimeUtc) {
        NSCalendar *localCalendar = [NSCalendar currentCalendar];
        NSCalendar *utcCalendar = [NSCalendar currentCalendar];
        utcCalendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        
        NSDateComponents *components = [utcCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.deliveryDateAndTime];
        _deliveryTimeUtc = [localCalendar dateFromComponents:components];
    }
    
    return _deliveryTimeUtc;
}

@dynamic deliveryAddress;
@dynamic items;
@dynamic totalPrice;
@dynamic status;
@dynamic driverLocation;

@synthesize shortNameToMenuOptionObject = _shortNameToMenuOptionObject;
@synthesize driverLocationMapItem;

- (MKMapItem *)driverLocationMapItem {
    double latitude = self.driverLocation.latitude;
    double longitude = self.driverLocation.latitude;
    return [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil]];
}

- (NSDictionary *)shortNameToMenuOptionObject {
    if (!_shortNameToMenuOptionObject) {
        NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithCapacity:self.items.count];
        for (NSString *optionName in self.items.keyEnumerator) {
            MenuOption *menuOption = [[ParseAPI getInstance] menuOptionForShortName:optionName];
            options[optionName] = menuOption;
        }
        _shortNameToMenuOptionObject = [NSDictionary dictionaryWithDictionary:options];
    }
    return _shortNameToMenuOptionObject;
}

@end
