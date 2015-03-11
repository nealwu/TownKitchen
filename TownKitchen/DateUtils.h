//
//  DateUtils.h
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSString *)dayOfTheWeekFromDate:(NSDate *)date;
+ (NSString *)monthAndDayFromDate:(NSDate *)date;

@end
