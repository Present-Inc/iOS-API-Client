//
//  PPlaylistConfig.m
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PPlaylistConfig.h"

@implementation PPlaylistConfig

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"targetDuration": @"targetDuration",
        @"windowLength": @"windowLength"
    };
}

@end
