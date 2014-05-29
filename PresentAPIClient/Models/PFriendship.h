//
//  PFriendship.h
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

@class PUser;
@class PUserResult;

@interface PFriendship : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PUserResult *targetUserResult;

+ (instancetype)friendshipWithUser:(PUser*)user;

- (PUser*)sourceUser;
- (PUser*)targetUser;

@end

@interface PFriendship (ResourceMethods)

+ (NSURLSessionDataTask*)createFriendshipWithUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)deleteFriendshipWithUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getForwardFriendshipsForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getBackwardFriendshipsForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
