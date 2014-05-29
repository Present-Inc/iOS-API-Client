//
//  PVideoSessionState.h
//  Present
//
//  Created by Justin Makaila on 2/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface PVideoSessionState : MTLModel <MTLJSONSerializing>

@property (assign, nonatomic, getter = shouldUploadOnWWAN) BOOL uploadOnWWAN;

@property (assign, nonatomic) BOOL shouldFinish;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (assign, nonatomic, getter = isDeleted) BOOL deleted;

@end
