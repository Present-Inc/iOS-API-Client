//
//  PPlaylistMeta.h
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface PPlaylistMeta : MTLModel <MTLJSONSerializing>

@property (readonly, nonatomic, copy) NSString *objectId;

@property (nonatomic) BOOL shouldBeAvailable;
@property (nonatomic) BOOL isAvailable;
@property (nonatomic) BOOL shouldFinish;
@property (nonatomic) BOOL isFinished;

@end
