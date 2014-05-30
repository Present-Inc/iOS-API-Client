//
//  PSubjectiveObjectMeta.m
//  Present
//
//  Created by Justin Makaila on 3/24/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PSubjectiveObjectMeta.h"

@implementation PSubjectiveObjectMeta

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"demand": @"demand",
        @"friendship": @"friendship",
        @"like": @"like"
    };
}

+ (NSValueTransformer*)JSONTransformerForKey:(NSString *)key {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PRelation.class];
}

@end
