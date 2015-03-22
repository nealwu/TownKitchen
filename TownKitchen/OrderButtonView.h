//
//  OrderButtonView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/21/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderButtonView;

@protocol OrderButtonViewDelegate <NSObject>

- (void)orderButtonPressedFromOrderButtonView:(OrderButtonView *)view;

@end

@interface OrderButtonView : UIView

@property (assign, nonatomic) int quantity;
@property (strong, nonatomic) NSNumber *price;

@property (weak, nonatomic) id<OrderButtonViewDelegate> delegate;

@end
