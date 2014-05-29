//
//  PVideo.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

#import <CoreLocation/CLLocation.h>

@class PUser;
@class PLocation;
@class PComment;
@class PPlace;
@class PUserResult;
@class PPlaceResult;

//#import "PUser.h"
//#import "PLocation.h"
//#import "PComment.h"
//#import "PPlace.h"
//#import "PResult.h"

@class MKMapView;

@interface PVideo : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *creatorUser;

@property (strong, nonatomic) NSString *title;

@property (readonly, strong, nonatomic) NSDate *startTime;
@property (readonly, strong, nonatomic) NSDate *endTime;

@property (nonatomic) NSInteger commentsCursor;
@property (strong, nonatomic) NSMutableArray *commentsArray;

@property (nonatomic) NSInteger likesCursor;
@property (strong, nonatomic) NSMutableArray *likesArray;

@property (readonly, weak, nonatomic) NSURL *watchURL;
@property (readonly, weak, nonatomic) NSURL *archivedURL;
@property (readonly, weak, nonatomic) NSURL *coverURL;
@property (readonly, weak, nonatomic) NSURL *hlsURL;

@property (nonatomic) NSInteger replyCount;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic) NSInteger viewCount;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic) NSInteger score;

@property (strong, nonatomic) NSString *targetVideoId;

// !!!: This needs to be cleaned up
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) PPlaceResult *placeResult;
@property (nonatomic) double lat;
@property (nonatomic) double lng;

@property (nonatomic, getter = isAvailable) BOOL available;
@property (nonatomic, getter = isReply) BOOL reply;

+ (instancetype)videoWithTitle:(NSString*)title location:(CLLocationCoordinate2D)location;

- (BOOL)isTitleValid;
- (BOOL)isLive;

- (void)toggleLike;
- (void)createView;

- (void)addComment:(PComment*)comment;
- (void)deleteComment:(PComment*)comment;

- (NSArray*)mostRecentComments;

- (CLLocationCoordinate2D)coordinate;

@end

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

#import "PFBOpenGraphProtocol.h"
#import "PTwitterShareProtocol.h"
#import "PSMSShareProtocol.h"
#import "PEmailShareProtocol.h"

@interface PVideo (Social) <PFBOpenGraphProtocol, PTwitterShareProtocol, PSMSShareProtocol, PEmailShareProtocol>

- (NSURL*)shareUrl;

- (void)shareToFacebook;
- (void)postToFacebook;
- (void)likeOnFacebook;

- (void)shareToTwitter;
- (void)postToTwitter;

@end
