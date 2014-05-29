//
//  PVideoSegment.m
//  Present
//
//  Created by Justin Makaila on 1/23/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PVideoSegment.h"
#import <NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation PVideoSegment

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"mediaSegment": @"mediaSegment",
        @"mediaSequence": @"mediaSequence",
        @"retryCount": @"retryCount"
    };
}

+ (NSValueTransformer*)urlJSONTransfromer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (instancetype)segment:(NSURL*)segmentURL forMediaSequence:(NSInteger)mediaSequence {
    PVideoSegment *newSegment = [[PVideoSegment alloc] init];
    newSegment.url = segmentURL;
    newSegment.mediaSequence = mediaSequence;
    newSegment.retryCount = 0;
    
    return newSegment;
}

@end
