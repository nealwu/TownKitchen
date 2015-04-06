//
//  PaymentViewController.h
//  TownKitchen
//
//  Created by Peter Bai on 4/5/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTKView.h"

@class PaymentViewController;

@protocol PaymentViewControllerDelegate <NSObject>

- (void)onSetPaymentButtonFromPaymentViewController:(PaymentViewController *)pvc withCardValidity:(BOOL)valid;

@end

@interface PaymentViewController : UIViewController

@property (strong, nonatomic) PTKView *paymentEntryView;
@property (assign, nonatomic) BOOL valid;
@property (weak, nonatomic) id<PaymentViewControllerDelegate> delegate;

@end
