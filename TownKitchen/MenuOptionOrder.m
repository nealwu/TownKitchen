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

+ (MenuOptionOrder *)initWithMenuOption:(MenuOption *)menuOption {
    MenuOptionOrder *menuOptionOrder = [[MenuOptionOrder alloc] init];
    menuOptionOrder.menuOption = menuOption;
    NSLog(@"initing menuoptionorder with quantity: %@", menuOptionOrder.quantity);
    return menuOptionOrder;
}

- (id)init {
    self = [super init];
    if (self) {
        self.quantity = @0;
    }
    return self;
}

- (NSNumber *)totalPrice{
    float price = [self.menuOption.price floatValue];
    float totalPrice = price * [self.quantity intValue];
    return [NSNumber numberWithFloat:totalPrice];
}

@end
