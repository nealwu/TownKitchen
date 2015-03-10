//
//  User.h
//  TownKitchen
//
//  Created by Miles Spielberg on 3/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *username;

@end
