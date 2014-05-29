//
//  PPlaylistConfig.h
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface PPlaylistConfig : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger targetDuration;
@property (nonatomic, assign) NSInteger windowLength;

@end
