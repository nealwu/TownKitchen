//
//  PaymentView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/19/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTKView.h"

@class PaymentView;

@protocol PaymentViewDelegate <NSObject>

- (void)onSetPaymentButtonFromPaymentView:(PaymentView *)view withCardValidity:(BOOL)valid;

@end

@interface PaymentView : UIView

@property (strong, nonatomic) PTKView *paymentEntryView;
@property (assign, nonatomic) BOOL valid;
@property (weak, nonatomic) id<PaymentViewDelegate> delegate;

@end
