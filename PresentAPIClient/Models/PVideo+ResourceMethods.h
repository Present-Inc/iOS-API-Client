//
//  PVideo+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PVideo.h"

@class PVideoSegment;
@class PPlaylistSession;
@interface PVideo (ResourceMethods)

// !!!: This seriously sucks
@property (strong, atomic) NSURLSessionDataTask *pollTask;
@property (assign, atomic) NSInteger pollRetryCount;
@property (assign, nonatomic) BOOL pollingIsCancelled;

+ (NSURLSessionDataTask*)getVideoWithId:(NSString*)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getFeedForCurrentUserWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getVideosForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getBrandNewVideosWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getPopularVideosWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getVideosNearPlace:(PPlace*)place withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getVideosMatchingTitle:(NSString*)title withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)deleteVideoWithId:(NSString*)objectId;
+ (NSURLSessionDataTask*)endVideoWithId:(NSString*)objectId;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)block;
- (NSURLSessionDataTask*)appendSegment:(PVideoSegment*)segment parameters:(NSDictionary*)parameters progress:(NSProgress**)progress success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)updateTitle:(NSString*)newTitle success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)updateLocation:(PLocation*)location success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)updatePlaceId:(NSString*)placeId success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)getLikesWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getCommentsWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)pollForAvailabilityWithSuccess:(PObjectResultBlock)success;
- (void)cancelPolling;

- (NSURLSessionDataTask*)showWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)hideWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)flagWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)endWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (BOOL)delete;

@end

