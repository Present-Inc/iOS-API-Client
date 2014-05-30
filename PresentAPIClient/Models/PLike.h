//
//  PLike.h
//  Present
//
//  Created by Justin Makaila on 3/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

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

@interface PLike (ResourceMethods)

+ (NSURLSessionDataTask*)createLikeForVideo:(PVideo*)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)deleteLikeForVideo:(PVideo*)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getLikedVideosForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getLikesForVideo:(PVideo*)video success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
