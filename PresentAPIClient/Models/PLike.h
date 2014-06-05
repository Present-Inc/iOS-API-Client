//
//  PLike.h
//  Present
//
//  Created by Justin Makaila on 3/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

@class PUser;
@class PVideo;
@class PUserResult;
@class PVideoResult;

@interface PLike : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PVideoResult *targetVideoResult;

+ (instancetype)likeForVideo:(PVideo*)video;

- (PUser*)sourceUser;
- (PVideo*)targetVideo;

@end
