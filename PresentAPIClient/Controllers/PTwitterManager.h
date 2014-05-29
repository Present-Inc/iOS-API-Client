//
//  PTwitterManager.h
//  Present
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Accounts/Accounts.h>

#import "PObject+Networking.h"

@class STTwitterAPI;
@class PUser;

@interface PTwitterManager : NSObject

@property (strong, nonatomic) STTwitterAPI *twitterAPI;

+ (PTwitterManager*)sharedManager;
+ (void)start;

+ (void)initializeWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
+ (void)setOAuthToken:(NSString*)token oAuthVerifier:(NSString*)verifier;

+ (BOOL)isLinkedWithUser:(PUser*)user;

+ (void)linkUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (void)unlinkUser:(PUser*)user success:(PObjectResultBlock)success error:(PFailureBlock)failure;

- (void)addAccountWithOAuthToken:(NSString*)oAuthToken oAuthSecret:(NSString*)oAuthSecret;

- (void)loginWithAccount:(ACAccount*)account;
- (void)loginWithAccount:(ACAccount*)account success:(PObjectResultBlock)success;
- (void)loginWithSafariWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (void)requestAccessToTwitterAccountsWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (void)postTweetWithMessage:(NSString*)message;

@end

static NSString *const PTwitterManagerErrorDomain = @"PTwitterManagerErrorDomain";
