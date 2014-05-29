//
//  PView.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

@class PUser;
@class PVideo;
@class PUserResult;
@class PVideoResult;

@interface PView : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *userResult;
@property (strong, nonatomic) PVideoResult *videoResult;

+ (void)createViewForVideo:(PVideo*)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (void)getViewsForUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (BOOL)isEqual:(id)object;

- (PUser*)user;
- (PVideo*)video;

@end
