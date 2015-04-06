//
//  SetPaymentButton.h
//  TownKitchen
//
//  Created by Peter Bai on 4/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetPaymentButton;

@protocol SetPaymentButtonDelegate <NSObject>

- (void)setPaymentButtonTapped:(SetPaymentButton *)setPaymentButton withValidity:(BOOL)validity;

@end

@interface SetPaymentButton : UIView

@property (weak, nonatomic) id<SetPaymentButtonDelegate> delegate;

- (void)setPaymentButtonValidity:(BOOL)valid;
- (void)setPaymentButtonValidity:(BOOL)valid animated:(BOOL)animated;

@end
