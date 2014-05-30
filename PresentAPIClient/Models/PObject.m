//
//  PObject.m
//  Present
//
//  Created by Justin Makaila on 3/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject.h"

#import "NSDate+ISO8601.h"

@interface PObject ()

@property (strong, nonatomic) NSString *_id;

@end

@implementation PObject

+ (NSValueTransformer*)dateTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *dateString) {
        return [NSDate dateFromISOString:dateString];
    }reverseBlock:^id (NSDate *date) {
        if ([date isKindOfClass:[NSDate class]]) {
            return [NSDate ISOStringFromDate:date];
        }else {
            return nil;
        }
    }];
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"_id": @"_id",
        @"creationDate": @"_creationDate",
        @"lastUpdatedAt": @"_lastUpdatedAt",
        @"clientId": NSNull.null,
    };
}

+ (NSValueTransformer*)creationDateJSONTransformer {
    return [[self class] dateTransformer];
}

+ (NSValueTransformer*)lastUpdatedAtJSONTransformer {
    return [[self class] dateTransformer];
}

- (BOOL)isNew {
    return !self._id;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        PObject *pObject = (PObject*)object;
        return ([self._id isEqualToString:pObject._id] || [self.clientId isEqualToString:pObject.clientId]);
    }
    
    return NO;
}

@end
