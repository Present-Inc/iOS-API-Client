//
//  PPlaylistSession.m
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PPlaylistSession.h"

#import <NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation PPlaylistSession

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"mediaSegments": @"mediaSegments",
        @"meta": @"meta",
        @"config": @"config"
    };
}

+ (NSValueTransformer*)metaJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PPlaylistMeta.class];
}

+ (NSValueTransformer*)configJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PPlaylistConfig.class];
}

@end
