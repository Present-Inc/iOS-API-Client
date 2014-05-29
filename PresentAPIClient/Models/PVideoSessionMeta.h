//
//  PVideoSessionMeta.h
//  Present
//
//  Created by Justin Makaila on 2/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <MTLJSONAdapter.h>

@interface PVideoSessionMeta : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSInteger fileNumber;
@property (nonatomic) NSInteger completedUploads;
@property (nonatomic) NSInteger failedUploads;
@property (nonatomic) NSInteger createRetryCount;

- (NSInteger)totalUploads;
- (BOOL)finishedUploads;

@end
