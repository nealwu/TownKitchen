//
//  DateUtils.m
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DateUtils.h"

static const NSCalendarUnit kYmdHmsComponents = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;

static const long kSecondsPerMinute = 60;
static const long kMinutesPerHour = 60;
static const long kSecondsPerHour = kSecondsPerMinute * kMinutesPerHour;

@implementation DateUtils

+ (NSString *)dayOfTheWeekFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    return [formatter stringFromDate:date];
}

+ (NSString *)monthAndDayFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d"];
    return [formatter stringFromDate:date];
}

+ (NSDate *)beginningOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:kYmdHmsComponents fromDate:date];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];

    return [calendar dateFromComponents:components];
}

+ (NSDate *)endOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:kYmdHmsComponents fromDate:date];

    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];

    return [calendar dateFromComponents:components];
}

+ (BOOL)compareDayFromDate:(NSDate *)date1 withDate:(NSDate *)date2 {
    return [[self beginningOfDay:date1] isEqualToDate:[self beginningOfDay:date2]];
}

+ (NSString *)approximateTimeStringFromInterval:(NSTimeInterval)interval {
    if (interval > 2 * kSecondsPerHour) {
        return [NSString stringWithFormat:@"%.0f hours", interval / kSecondsPerHour];
    }
    if (interval > kSecondsPerHour) {
        return @"an hour";
    }
    if (interval > 5 * kSecondsPerMinute) {
        return [NSString stringWithFormat:@"%.0f minutes", interval / kSecondsPerMinute];
    }
    return @"under 5 minutes";
}

@end
