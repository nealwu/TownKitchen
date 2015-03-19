//
//  PayAndOrderButton.h
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ButtonState) {
    ButtonStateEnterPayment = 0,
    ButtonStatePlaceOrder = 1
};

@interface PayAndOrderButton : UIButton

@property (assign, nonatomic) ButtonState buttonState;

@end
