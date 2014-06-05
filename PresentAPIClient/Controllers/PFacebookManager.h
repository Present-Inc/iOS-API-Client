//
//  PFacebookManager.h
//  Present
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Facebook.h>

#import "PUser.h"
#import "PFBOpenGraphProtocol.h"

@interface PFacebookManager : NSObject

+ (FBSession*)session;
+ (PFacebookManager*)sharedManager;
+ (void)start;

+ (void)initializeFacebook;

+ (BOOL)isLinkedWithUser:(PUser*)user;

+ (void)linkUser:(PUser*)user success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+ (void)unlinkUser:(PUser*)user success:(void (^)(id))success failure:(void (^)(NSError *))failure;

+ (void)requestPublishPermissionsWithSuccess:(void (^)())success;

+ (FBSessionStateHandler)sessionCompletionHandlerWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;

- (void)requestAccessToFacebookAccountsWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end

@interface PFacebookManager (Sharing)

+ (void)postObject:(id<PFBOpenGraphProtocol>)object withAction:(NSString*)action;

@end

@interface PFacebookManager (Deprecated)
@end

static NSString *const PFacebookManagerErrorDomain = @"PFacebookManagerErrorDomain";
