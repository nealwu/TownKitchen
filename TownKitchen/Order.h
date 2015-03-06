//
//  Order.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"

typedef enum : NSUInteger {
    TKOrderStateBeingPrepared,
    TKOrderStateOutForDelivery,
    TKOrderSTateDelivered
} TKOrderState;

@interface Order : PFObject

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) User *driver;
@property (nonatomic) BOOL isReviewed;

@end
