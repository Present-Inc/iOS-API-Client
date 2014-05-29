//
//  PVideoSessionState.m
//  Present
//
//  Created by Justin Makaila on 2/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PVideoSessionState.h"

@implementation PVideoSessionState

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"finished": @"isFinished",
        @"deleted": @"isDeleted",
        @"shared": @"wasShared",
    };
}

+ (NSDictionary*)encodingBehaviorsByPropertyKey {
    NSDictionary *behaviors = [super encodingBehaviorsByPropertyKey];
    return behaviors;
}

+ (NSValueTransformer*)finishedJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer*)uploadOnWWANJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer*)deletedJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer*)sharedJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
