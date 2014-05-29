//
//  PPlaylistSession.h
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import "PPlaylistConfig.h"
#import "PPlaylistMeta.h"

@interface PPlaylistSession : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSMutableArray *mediaSegments;
@property (strong, nonatomic) PPlaylistConfig *config;
@property (strong, nonatomic) PPlaylistMeta *meta;

@end

