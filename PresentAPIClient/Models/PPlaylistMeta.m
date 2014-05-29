//
//  PPlaylistMeta.m
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PPlaylistMeta.h"

#import <NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation PPlaylistMeta

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"objectId": @"id",
    };
}

+ (NSValueTransformer*)shouldBeAvailableJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer*)isAvailableJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer*)isFinishedJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer*)shouldFinishJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
