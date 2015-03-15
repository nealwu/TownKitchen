//
//  DateUtils.m
//  TownKitchen
//
//  Created by Neal Wu on 3/11/15.
//  Copyright (c) 2015 The Town Kitchen. All rights reserved.
//

#import "DateUtils.h"

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

+ (BOOL)compareDayFromDate:(NSDate *)date1 withDate:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components1 = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date1];
    NSDateComponents *components2 = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date2];
    return [components1 day] == [components2 day];
}

@end
