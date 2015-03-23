//
//  NSValue+CLLocationCoordinate2D.m
//  TownKitchen
//
//  Created by Miles Spielberg on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "NSValue+CLLocationCoordinate2D.h"

@implementation NSValue (CLLocationCoordinate2D)

+ (instancetype)valueWithCoordinate:(CLLocationCoordinate2D)coordinate{
    return [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
}

- (CLLocationCoordinate2D) coordinateValue {
    CLLocationCoordinate2D coordinate;
    [self getValue:&coordinate];
    return coordinate;
}

@end
