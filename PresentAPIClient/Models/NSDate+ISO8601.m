//
//  NSDate+ISO8601.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/28/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "NSDate+ISO8601.h"

@implementation NSDate (ISO8601)

+ (NSString*)ISOStringFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    dateString = [dateString stringByAppendingString:@"Z"];
    return dateString;
}

+ (NSDate*)dateFromISOString:(NSString*)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    
    return [dateFormatter dateFromString:dateString];
}

@end
