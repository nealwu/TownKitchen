//
//  TKNavigationBar.m
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "TKNavigationBar.h"

@interface TKNavigationBar ()



@end

@implementation TKNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    self.translucent = NO;
    self.barTintColor = [UIColor colorWithRed:235.0 / 255
                                        green:92.0 / 255
                                         blue:87.0 / 255
                                        alpha:1.0];
    self.tintColor = [UIColor whiteColor];  
}

@end
