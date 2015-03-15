//
//  CircleStepperView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/15/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleStepperView;

@protocol CircleStepperViewDelegate <NSObject>

- (void)circleStepperView:(CircleStepperView *)circleStepperView didUpdateValue:(int)value;

@end

@interface CircleStepperView : UIView

@property (assign, nonatomic) int value;
@property (weak, nonatomic) id<CircleStepperViewDelegate> delegate;

@end
