//
//  PDemand.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

@class PUser;
@class PUserResult;

@interface PDemand : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PUserResult *targetUserResult;

+ (instancetype)demandForUser:(PUser*)user;

- (BOOL)isEqual:(id)object;

- (PUser*)sourceUser;
- (PUser*)targetUser;

@end

@interface PDemand (ResourceMethods)

+ (NSURLSessionDataTask*)deleteDemandForUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getForwardDemandsForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getBackwardDemandsForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
