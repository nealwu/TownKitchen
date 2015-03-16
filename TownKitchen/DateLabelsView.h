//
//  DateLabelsView.h
//  TownKitchen
//
//  Created by Peter Bai on 3/16/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateLabelsView : UIView

@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthAndDayLabel;

- (void)shrinkToHeaderSizeWithAnimation:(BOOL)animated;
- (void)returnToNormalSizeWithAnimation:(BOOL)animated;

@end
