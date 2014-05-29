//
//  MHNetworkCommunications.h
//  MHacksHLSUpstream
//
//  Created by Justin Makaila on 9/21/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class PVideoSession;
@class PVideo;

/**
 *  Provides an interface for interacting with video sessions;
 */
@interface PVideoSessionManager : AFHTTPSessionManager <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (readonly, strong, nonatomic) NSNumber *totalProgress;

@property (readonly, strong, nonatomic) NSMutableArray *sessions;

@property (readonly, strong, nonatomic) PVideoSession *currentSession;

@property (readonly, strong, nonatomic) NSNumber *jobCount;

@property (readonly, nonatomic, getter = isSuspended) BOOL suspended;
@property (readonly, nonatomic, getter = isRunning) BOOL running;

+ (instancetype)sharedManager;

- (void)shutdown;

- (void)createVideo:(PVideo*)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (void)appendFile:(NSURL *)target isLastSegment:(BOOL)lastSegment;
- (void)uploadOnWWANGranted:(BOOL)granted;

- (void)retryCurrentSession;
- (void)cancelCurrentSession;

@end

extern NSString *const PNetworkClientRequireUserPermission;
extern NSString *const PNetworkClientDidStartNotification;
extern NSString *const PNetworkClientDidEndNotification;
extern NSString *const PNetworkClientDidFinishPostingFile;
extern NSString *const PNetworkClientDidFailWithError;