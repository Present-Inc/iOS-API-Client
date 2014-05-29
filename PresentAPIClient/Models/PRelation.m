//
//  PRelation.m
//  PConnections
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PRelation.h"

@implementation PRelation

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"forward": @"forward",
        @"backward": @"backward"
    };
}

+ (instancetype)relationForward:(BOOL)forward backward:(BOOL)backward {
    PRelation *relation = [[PRelation alloc] init];
    relation.forward = forward;
    relation.backward = backward;
    
    return relation;
}

@end
