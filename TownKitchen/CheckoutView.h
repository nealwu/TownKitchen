//
//  CheckoutView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/18/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayAndOrderButton.h"
#import "Order.h"

@interface CheckoutView : UIView

@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) NSArray *menuOptionShortNames;
@property (strong, nonatomic) NSDictionary *shortNameToObject;
@property (weak, nonatomic) IBOutlet PayAndOrderButton *orderButton;

@end
