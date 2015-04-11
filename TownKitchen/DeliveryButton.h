//
//  DeliveryButton.h
//  TownKitchen
//
//  Created by Peter Bai on 4/10/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonState) {
    ButtonStateInactive,
    ButtonStateActive
};

@interface DeliveryButton : UIButton

@property (nonatomic, assign) BOOL active;

- (void)setButtonState:(ButtonState)state animated:(BOOL)animated;

@end
