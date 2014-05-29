//
//  PVideoAPIManager.h
//  Present
//
//  Created by Justin Makaila on 2/26/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import "PJSONResponseSerializer.h"

@class PUserContext;

typedef void (^AFNetworkingSuccessBlock) (NSURLSessionDataTask *, NSDictionary *);
typedef void (^AFNetworkingFailureBlock) (NSURLSessionDataTask *, NSError *);

typedef void (^PObjectResultBlock) (id object);
typedef void (^PCollectionResultsBlock) (NSArray *results, NSInteger nextCursor);
typedef void (^PFailureBlock) (NSError *error);

@interface PAPIManager : AFHTTPSessionManager

+ (void)start;
+ (instancetype)sharedManager;

- (void)setUserContext:(PUserContext*)userContext;
- (void)clearUserContext;

- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;
- (BOOL)isReachable;

- (void)cancelTasksWithDescription:(NSString *)description;
- (void)cancelTasksWithIdentifier:(NSUInteger)identifier;

- (NSURLSessionDataTask*)getResource:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getCollectionAtResource:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)post:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)postCollection:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionUploadTask*)uploadTaskWithStreamedRequest:(NSURLRequest*)request progress:(NSProgress**)progress success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
