//
//  PVideoSegment.h
//  Present
//
//  Created by Justin Makaila on 1/23/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface PVideoSegment : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSURL *url;
@property (nonatomic) NSInteger mediaSequence;
@property (nonatomic) NSInteger retryCount;

+ (instancetype)segment:(NSURL*)segmentURL forMediaSequence:(NSInteger)mediaSequence;

@end
