//
//  NSValue+CLLocationCoordinate2D.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/22/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSValue (CLLocationCoordinate2D)

+ (instancetype)valueWithCoordinate:(CLLocationCoordinate2D)coordinate;
@property (readonly) CLLocationCoordinate2D coordinateValue;

@end
