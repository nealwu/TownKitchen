//
//  PayAndOrderButton.m
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "PayAndOrderButton.h"

@implementation PayAndOrderButton

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
}

@end
