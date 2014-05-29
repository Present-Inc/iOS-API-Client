//
//  NSDate+ISO8601.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/28/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601)

+ (NSString*)ISOStringFromDate:(NSDate*)date;
+ (NSDate*)dateFromISOString:(NSString*)dateString;

@end
