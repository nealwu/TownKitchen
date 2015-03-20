//
//  PaymentView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/19/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaymentView;

@protocol PaymentViewDelegate <NSObject>

- (void)onSetPaymentButtonFromPaymentView:(PaymentView *)view;

@end

@interface PaymentView : UIView

@end
