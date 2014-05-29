//
//  PUserContext.h
//  Present
//
//  Created by Justin Makaila on 3/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

@class PUserResult;

@interface PUserContext : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *userResult;
@property (strong, nonatomic) NSString *sessionToken;

+ (PUserContext*)currentContext;

+ (void)setDeviceToken:(NSData*)token;

- (void)saveToDisk;

@end

@interface PUserContext (ResourceMethods)

+ (NSURLSessionDataTask*)authenticateWithCredentials:(NSDictionary *)credentials success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)updateDeviceIdentifier;

+ (void)logOut;

@end
