//
//  PPlace.m
//  Present
//
//  Created by Justin Makaila on 5/1/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PPlace.h"

#import "PResult.h"
#import "PLocation.h"

@implementation PPlace

+ (NSString*)classResource {
    return @"places";
}

+ (Class)resourceResultClass {
    return PPlaceResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"fourSquareVenueId": @"fourSquareVenueId",
        @"name": @"name",
        @"location": @"location",
        @"videosCount": @"videos.count",
        @"videos": @"videos.results"
    }];
}

+ (NSValueTransformer*)locationJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PLocation.class];
}

@end
