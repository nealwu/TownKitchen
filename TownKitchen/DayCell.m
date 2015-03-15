//
//  DayViewCell.m
//  TownKitchen
//
//  Created by Neal Wu on 3/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DayCell.h"

@interface DayCell ()

@end

@implementation DayCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundImageView.alpha = 0.5;
    }
    else {
        self.backgroundImageView.alpha = 1.0;
    }
}

@end
