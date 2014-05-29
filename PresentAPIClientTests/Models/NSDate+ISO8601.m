//
//  NSDate+8601Spec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/28/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSDate+ISO8601.h"


SPEC_BEGIN(NSDate_ISO8601Spec)

describe(@"NSDate+ISO8601", ^{
    __block NSString *JSONDateString = @"2014-05-15T05:09:08.000Z";
    
    it (@"can convert an ISO 8601 String to an NSDate in the local time zone", ^{
        NSDate *date = [NSDate dateFromISOString:JSONDateString];
        [[date should] beNonNil];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSUInteger componentFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
        
        NSDateComponents *components = [calendar components:componentFlags fromDate:date];
        
        [[theValue([components year]) should] equal:theValue(2014)];
        [[theValue([components month]) should] equal:theValue(5)];
        [[theValue([components day]) should] equal:theValue(15)];
        [[theValue([components hour]) should] equal:theValue(1)];
        [[theValue([components minute]) should] equal:theValue(9)];
        [[theValue([components second]) should] equal:theValue(8)];
    });
    
    it (@"can convert an NSDate to an ISO 8601 String in GMT", ^{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:2014];
        [components setMonth:5];
        [components setDay:15];
        [components setHour:1];
        [components setMinute:9];
        [components setSecond:8];
        [components setTimeZone:[NSTimeZone localTimeZone]];
        
        NSDate *date = [calendar dateFromComponents:components];
        NSString *dateString = [NSDate ISOStringFromDate:date];
        [[dateString should] equal:JSONDateString];
    });
});

SPEC_END
