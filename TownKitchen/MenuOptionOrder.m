//
//  MenuOptionOrder.m
//  TownKitchen
//
//  Created by Peter Bai on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "MenuOptionOrder.h"

@implementation MenuOptionOrder

#pragma mark Custom Getters

- (NSNumber *)totalPrice{
    float price = [self.menuOption.price floatValue];
    float totalPrice = price * [self.quantity intValue];
    return [NSNumber numberWithFloat:totalPrice];
}

@end
