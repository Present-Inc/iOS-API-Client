//
//  PVideo.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright  2013 Present, Inc. All rights reserved.
//

#import "PVideo.h"

#import "PLocation.h"
#import "PLike.h"
#import "PRelationship.h"
#import "PView.h"
#import "PResult.h"
#import "PUser+SubjectiveObjectMeta.h"
#import "PComment.h"
#import "PPlace.h"

#import "PExternalServices.h"
#import "PSocialData.h"

#import "PSocialManager.h"

#import <objc/runtime.h>
#import <NSArray+Convenience.h>

@interface PVideo ()

@property (strong, nonatomic) NSString *archivedUrlString;
@property (strong, nonatomic) NSString *hlsUrlString;
@property (strong, nonatomic) NSString *coverUrlString;
@property (strong, nonatomic) NSString *shareUrlString;

@end

static NSString *videoIdKey         = @"video_id";
static NSString *mediaSequenceKey   = @"media_sequence";
static NSString *playlistSessionKey = @"playlist_session";
static NSString *mediaSegmentKey    = @"media_segment";

@implementation PVideo

#pragma mark PObject Protocol

+ (NSString*)classResource {
    return @"videos";
}

+ (Class)resourceResultClass {
    return PVideoResult.class;
}

#pragma mark MTLJSONSerilizing

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"creatorUserResult": @"creatorUser",
        @"startTime": @"creationTimeRange.startDate",
        @"endTime": @"creationTimeRange.endDate",
        @"commentCount": @"comments.count",
        @"commentsArray": @"comments.results",
        @"commentsCursor": @"comments.cursor",
        @"views": @"views.count",
        @"likeCount": @"likes.count",
        @"coverUrlString": @"mediaUrls.images.480px",
        @"hlsUrlString": @"mediaUrls.playlists.live.master",
        @"archivedUrlString": @"mediaUrls.playlists.replay.master",
        @"available": @"isAvailable",
        @"reply": @"isReply",
        @"replyCount": @"replies.count",
        @"lat": @"location.lat",
        @"lng": @"location.lng",
        @"placeResult": @"location.place",
        @"targetVideoId": @"targetVideo",
        @"shareUrlString": NSNull.null,
        @"likesCursor": NSNull.null,
        @"likesArray": NSNull.null,
    }];
}

+ (NSDictionary*)encodingBehaviorsByPropertyKey {
    NSSet *setToRemove = [NSSet setWithObjects:@"creator", @"commentsCursor", @"commentsArray", @"likesCursor", @"likesArray", @"commentCount", @"viewCount", @"likeCount", @"score", @"coordinate", nil];
    return [[super encodingBehaviorsByPropertyKey] mtl_dictionaryByRemovingEntriesWithKeys:setToRemove];
}

+ (NSValueTransformer*)creatorUserResultJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PUserResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^NSDictionary * (PUserResult *userResult) {
        if ([userResult isKindOfClass:[PUserResult class]]) {
            return [MTLJSONAdapter JSONDictionaryFromModel:userResult];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)commentsArrayJSONTransformer {
    /**
     *  Forward transformer should convert each NSDictionary to a PComment
     *  Reverse transformer does not send comments back over the network
     */
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSMutableArray* (NSArray *commentsJSONArray) {
        NSMutableArray *commentsArray = [NSMutableArray array];
        for (NSDictionary *commentJSON in commentsJSONArray) {
            PCommentResult *result = [MTLJSONAdapter modelOfClass:PCommentResult.class fromJSONDictionary:commentJSON error:nil];
            [commentsArray addObject:result.comment];
        }
        
        return [NSMutableArray arrayWithArray:[commentsArray sortedArray]];
    } reverseBlock:^id (NSMutableArray *array) {
        return nil;
    }];
}

+ (NSValueTransformer*)placeResultJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PPlaceResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^NSDictionary * (PPlaceResult *placeResult) {
        if (placeResult) {
            return [MTLJSONAdapter JSONDictionaryFromModel:placeResult];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)startTimeJSONTransformer {
    return [PVideo dateTransformer];
}

+ (NSValueTransformer*)endTimeJSONTransformer {
    return [PVideo dateTransformer];
}

+ (instancetype)videoWithTitle:(NSString *)title location:(CLLocationCoordinate2D)location {
    PVideo *video = [PVideo object];
    video.title = title;
    video.lat = location.latitude;
    video.lng = location.longitude;
    
    return video;
}

- (void)mergePlaceResultFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.placeResult) {
        return;
    }else if (video.placeResult && !self.placeResult) {
        self.placeResult = video.placeResult;
    }
}

- (void)mergeCreatorUserFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.creatorUserResult) {
        return;
    }else if (video.creatorUserResult && !self.creatorUserResult) {
        self.creatorUserResult = video.creatorUserResult;
    }
}

- (void)mergeLatFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.lat) {
        return;
    }else {
        self.lat = video.lat;
    }
}

- (void)mergeLngFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.lng) {
        return;
    }else {
        self.lng = video.lng;
    }
}

- (void)mergeEndTimeFromModel:(MTLModel*)model {
    PVideo *video = (PVideo*)model;
    
    if (!video.endTime) {
        return;
    }else if (video.endTime) {
        _endTime = video.endTime;
    }
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _startTime = [NSDate date];
    }
    
    return self;
}

#pragma mark - Accessors/Mutators
#pragma mark Accessors

- (BOOL)isLive {
    return !_endTime;
}

- (BOOL)isTitleValid {
    return !(!self.title || [self.title isEqual:@"No title"] || [self.title isEqual:@""]);
}

- (NSString*)title {
    if (!_title) {
        _title = @"";
    }
    
    return _title;
}

- (NSString*)shareUrlString {
    return [NSString stringWithFormat:@"http://www.present.tv/%@/p/%@", self.creatorUserResult.user.username, self._id];
}

- (NSURL*)watchURL {
    return (self.isLive) ? self.hlsURL : self.archivedURL;
}

- (NSURL*)archivedURL {
    return [NSURL URLWithString:self.archivedUrlString];
}

- (NSURL*)hlsURL {
    return [NSURL URLWithString:self.hlsUrlString];
}

- (NSURL*)coverURL {
    return [NSURL URLWithString:self.coverUrlString];
}

- (NSArray*)mostRecentComments {
    static NSInteger const kMostRecentCommentsToDisplay = 4;
    
    if (_commentsArray.count == 0) {
        return nil;
    }
    
    NSInteger start = 0;
    NSInteger length = 0;
    if (_commentsArray.count > 0 && _commentsArray.count < kMostRecentCommentsToDisplay) {
        length = _commentsArray.count;
    }else {
        start = _commentsArray.count - kMostRecentCommentsToDisplay;
        length = kMostRecentCommentsToDisplay;
    }
    
    return [[_commentsArray subarrayWithRange:NSMakeRange(start, length)] sortedArray];
}

- (PUser*)creatorUser {
    return self.creatorUserResult.user;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.lat, self.lng);
}

- (NSMutableArray*)commentsArray {
    if (!_commentsArray) {
        _commentsArray = [NSMutableArray array];
    }
    
    return _commentsArray;
}

- (NSMutableArray*)likesArray {
    if (!_likesArray) {
        _likesArray = [NSMutableArray array];
    }
    
    return _likesArray;
}

#pragma mark Mutators

- (void)toggleLike {
    [PUser currentUser].likes.to(self) ? [self deleteLike] : [self createLike];
}

- (void)createLike {
    [self willChangeValueForKey:@"likeCount"];
    self.likeCount++;
    [self didChangeValueForKey:@"likeCount"];

    [PLike createLikeForVideo:self
                      success:nil
                      failure:nil];
    
    [PUser currentUser].likes.setForward(self, YES);
    
    if ([PUser currentUser].externalServices.facebook.shareLikes) {
        [self likeOnFacebook];
    }
}

- (void)deleteLike {
    [self willChangeValueForKey:@"likeCount"];
    self.likeCount--;
    [self didChangeValueForKey:@"likeCount"];
    
    [PLike deleteLikeForVideo:self
                      success:nil
                      failure:nil];
    
    [PUser currentUser].likes.setForward(self, NO);
}

- (void)createView {
    [PView createViewForVideo:self
                      success:nil
                      failure:nil];
}

/**
 *  Adds a comment
 *
 *  @param comment The comment to add
 */
- (void)addComment:(PComment *)comment {
    if (![self.commentsArray containsObject:comment]) {
        [self.commentsArray addObject:comment];
        
        [self willChangeValueForKey:@"commentCount"];
        self.commentCount++;
        [self didChangeValueForKey:@"commentCount"];
    }
}

/**
 *  Deletes a comment
 *
 *  @param commentToDelete The comment to delete
 */
- (void)deleteComment:(PComment*)commentToDelete {
    [self.commentsArray removeObject:commentToDelete];
    
    [PComment deleteComment:commentToDelete success:nil failure:nil];
    
    [self willChangeValueForKey:@"commentCount"];
    self.commentCount--;
    [self didChangeValueForKey:@"commentCount"];
}

- (void)end {
    _endTime = [NSDate date];
}

@end

#pragma mark - Resource Methods

#import "PVideoSegment.h"
#import "PPlaylistSession.h"

@implementation PVideo (ResourceMethods)

@dynamic pollTask;
@dynamic pollRetryCount;

#pragma mark Resources

+ (NSString*)createReplyResource {
    return [self resourceWithString:@"create_reply"];
}

+ (NSString*)appendResource {
    return [self resourceWithString:@"append"];
}

+ (NSString*)listHomeVideosResource {
    return [self resourceWithString:@"list_home_videos"];
}

+ (NSString*)listUserVideosResource {
    return [self resourceWithString:@"list_user_videos"];
}

+ (NSString*)listBrandNewVideosResource {
    return [self resourceWithString:@"list_brand_new_videos"];
}

+ (NSString*)listPopularVideosResource {
    return [self resourceWithString:@"list_popular_videos"];
}

+ (NSString*)searchResource {
    return [self resourceWithString:@"search"];
}

+ (NSString*)hideResource {
    return [self resourceWithString:@"hide"];
}

+ (NSString*)listPlaceVideos {
    return [self resourceWithString:@"list_place_videos"];
}

#pragma mark Class Methods

+ (NSURLSessionDataTask*)getVideoWithId:(NSString *)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *videoParameters = @{
        @"video_id": objectId
    };
    
    return [PVideo getResource:[PVideo showResource]
                withParameters:videoParameters
                       success:success
                       failure:failure];
}

+ (NSURLSessionDataTask*)getFeedForCurrentUserWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSDictionary *videoParameters = nil;
    
    if (cursor > 0) {
        videoParameters = @{
            @"cursor": @(cursor)
        };
    }
    
    return [PVideo getCollectionAtResource:[PVideo listHomeVideosResource]
                            withParameters:videoParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)getVideosForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *videoParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": user._id,
    }];
    
    if (user.videosCursor > 0) {
        [videoParameters setObject:@(user.videosCursor) forKey:@"cursor"];
    }
    
    return [PVideo getCollectionAtResource:[PVideo listUserVideosResource]
                            withParameters:videoParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)getBrandNewVideosWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSDictionary *videoParameters;
    if (cursor > 0) {
        videoParameters = @{
            @"cursor": @(cursor)
        };
    }
    
    return [PVideo getCollectionAtResource:[PVideo listBrandNewVideosResource]
                            withParameters:videoParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)getPopularVideosWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *videoParameters = [NSMutableDictionary dictionary];
    
    if (cursor > 0) {
        [videoParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PVideo getCollectionAtResource:[PVideo listPopularVideosResource]
                            withParameters:videoParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)getVideosNearPlace:(PPlace *)place withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *placeParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"place_id": place._id
    }];
    
    if (cursor > 0) {
        [placeParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PVideo getCollectionAtResource:[PVideo listPlaceVideos]
                            withParameters:placeParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)getVideosMatchingTitle:(NSString *)title withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"query": title
    }];
    
    if (cursor > 0) {
        [searchParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PVideo getCollectionAtResource:[PVideo searchResource]
                            withParameters:searchParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)endVideoWithId:(NSString *)objectId {
    NSDictionary *videoParameters = @{
        @"video_id": objectId
    };
    
    return [PVideo post:[PVideo updateResource]
         withParameters:videoParameters
                success:nil
                failure:nil];
}

+ (NSURLSessionDataTask*)deleteVideoWithId:(NSString*)objectId {
    NSDictionary *videoParameters = @{
        @"video_id": objectId
    };
    
    return [PVideo post:[PVideo destroyResource]
         withParameters:videoParameters
                success:nil
                failure:nil];
}

#pragma mark Instance Methods

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *createParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"title": self.title,
    }];
    
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        [createParameters setObject:[NSString stringWithFormat:@"%f,%f", self.coordinate.latitude, self.coordinate.longitude] forKey:@"lat_lng"];
    }
    
    if (self.placeId && ![self.placeId isEqualToString:@""]) {
        [createParameters setObject:self.placeId forKey:@"place_id"];
    }
    
    if (self.isReply) {
        [createParameters setObject:self.targetVideoId forKey:@"reply_target_video_id"];
    }
    
    NSURLSessionDataTask *task = [PVideo post:self.isReply ? [PVideo createReplyResource] : [PVideo createResource]
                               withParameters:createParameters
                                      success:success
                                      failure:failure];
    
    task.taskDescription = [self._id copy];
    
    return task;
}

- (NSURLSessionDataTask*)updateTitle:(NSString *)newTitle success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    self.title = newTitle;
    
    NSDictionary *updateParameters = @{
        @"title": newTitle,
        @"video_id": self._id
    };
    
    return [PVideo post:[PVideo updateResource]
         withParameters:updateParameters
                success:success
                failure:failure];
}

- (NSURLSessionDataTask*)appendSegment:(PVideoSegment *)segment parameters:(NSDictionary *)parameters progress:(NSProgress**)progress success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    void (^constructingBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        NSError *error;
        [formData appendPartWithFileURL:segment.url
                                   name:mediaSegmentKey
                               fileName:[NSString stringWithFormat:@"%@_%li.mp4", self._id, (long)segment.mediaSequence]
                               mimeType:@"video/mp4"
                                  error:&error];
    };
    
    NSURLSessionDataTask *task = [PVideo post:[PVideo appendResource]
                   multipartFormDataWithBlock:constructingBlock
                                     progress:progress
                                   parameters:parameters
                                      success:success
                                      failure:failure];
    
    task.taskDescription = [self._id copy];
    
    return task;
}

- (NSURLSessionDataTask*)updateLocation:(PLocation *)location success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    self.lat = location.latitude;
    self.lng = location.longitude;
    
    if (!self.isNew && location) {
        NSDictionary *updateParameters = @{
            @"video_id": self._id,
            @"lat_lng": location.toString
        };
        
        return [PVideo post:[PVideo updateResource]
             withParameters:updateParameters
                    success:success
                    failure:failure];
    }
    
    return nil;
}

- (NSURLSessionDataTask*)updatePlaceId:(NSString *)placeId success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    self.placeId = placeId;
    
    if (!self.isNew && placeId) {
        NSDictionary *updateParameters = @{
            @"place_id": placeId,
            @"video_id": self._id
        };
        
        return [PVideo post:[PVideo updateResource]
             withParameters:updateParameters
                    success:^(PVideoResult *result) {
                        self.placeResult = result.video.placeResult;
                        
                        if (success) {
                            success(result);
                        }
                    }
                    failure:failure];
    }
    
    return nil;
}

- (NSURLSessionDataTask*)updateProperties:(NSDictionary*)properties success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *updateParameters = [properties mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"video_id": self._id
    }];
    
    return [PVideo post:[PVideo updateResource]
         withParameters:updateParameters
                success:success
                failure:failure];
}

- (NSURLSessionDataTask*)hideWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *hideParameters = @{
        @"video_id": self._id
    };
    
    return [PVideo post:[PVideo hideResource]
         withParameters:hideParameters
                success:success
                failure:failure];
}

- (NSURLSessionDataTask*)getLikesWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (_likesCursor == 0) {
            [_likesArray removeAllObjects];
        }
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:results.count];
        for (PLikeResult *result in results) {
            PUser *user = result.like.sourceUser;
            [users addObject:user];
            
            [[PUser currentUser] addSubjectiveRelationships:result.subjectiveObjectMeta forObject:user];
        }
        
        [_likesArray addObjectsFromArray:users];
        
        if (success) {
            success(results, nextCursor);
        }
        
        _likesCursor = nextCursor;
    };
    
    return [PLike getLikesForVideo:self
                           success:successBlock
                           failure:failure];
}

- (NSURLSessionDataTask*)getCommentsWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (_commentsCursor == 0) {
            [_commentsArray removeAllObjects];
        }
        
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:results.count];
        for (PCommentResult *result in results) {
            PComment *comment = result.comment;
            
            comment.targetVideoResult = [[PVideoResult alloc] init];
            comment.targetVideoResult.video = self;
            comment.targetVideoResult.subjectiveObjectMeta.like = [PUser currentUser].likes.get(self);
            
            [comments addObject:comment];
        }
        
        [_commentsArray addObjectsFromArray:[comments sortedArray]];

        if (success) {
            success(results, nextCursor);
        }
        
        _commentsCursor = nextCursor;
    };
    
    return [PComment getCommentsForVideo:self
                                 success:successBlock
                                 failure:failure];
}

- (NSURLSessionDataTask*)pollForAvailabilityWithSuccess:(PObjectResultBlock)success {
    PObjectResultBlock completionHandler = ^(PVideoResult *videoResult) {
        PVideo *video = videoResult.video;
        
        if (video.isAvailable) {
            [self mergeValuesForKeysFromModel:video];
            
            if (success) {
                success(self);
            }
        }else {
            if (self.pollRetryCount < 12) {
                @synchronized(self) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
                        sleep(5);
                        if (![self pollingIsCancelled]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self pollForAvailabilityWithSuccess:success];
                            });
                        }
                    });
                }
            }
        }
    };
    
    NSURLSessionDataTask *task = [self showWithSuccess:completionHandler failure:nil];
    
    [self setPollTask:task];
    self.pollRetryCount = self.pollRetryCount + 1;
    
    return task;
}

- (void)cancelPolling {
    [self setPollingIsCancelled:YES];
    [[self pollTask] cancel];
    [self setPollTask:nil];
}

- (NSURLSessionDataTask*)showWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *showParameters = @{
        @"video_id": self._id
    };
    
    return [PVideo getResource:[PVideo showResource]
                withParameters:showParameters
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)flagWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSLog(@"%s is not yet implemented", __PRETTY_FUNCTION__);
    return nil;
}

- (NSURLSessionDataTask*)endWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    [self end];
    NSLog(@"%s is not yet implemented", __PRETTY_FUNCTION__);
    return nil;
}

- (BOOL)delete {
    if (!self.isNew) {
        [PVideo deleteVideoWithId:self._id];
        return YES;
    }
    
    return NO;
}

- (void)setPollTask:(NSURLSessionDataTask *)pollTask {
    if ([self pollTask]) {
        [[self pollTask] cancel];
        [self associateValue:nil withKey:@selector(pollTask) associationPolicy:OBJC_ASSOCIATION_RETAIN];
    }
    
    [self associateValue:pollTask withKey:@selector(pollTask) associationPolicy:OBJC_ASSOCIATION_RETAIN];
}

- (NSURLSessionDataTask*)pollTask {
    return [self associatedValueForKey:@selector(pollTask)];
}

- (void)setPollRetryCount:(NSInteger)pollRetryCount {
    [self associateValue:@(pollRetryCount) withKey:@selector(pollRetryCount) associationPolicy:OBJC_ASSOCIATION_ASSIGN];
}

- (NSInteger)pollRetryCount {
    return [[self associatedValueForKey:@selector(pollRetryCount)] integerValue];
}

- (void)setPollingIsCancelled:(BOOL)pollingIsCancelled {
    [self associateValue:@(pollingIsCancelled) withKey:@selector(pollingIsCancelled) associationPolicy:OBJC_ASSOCIATION_ASSIGN];
}

- (BOOL)pollingIsCancelled {
    return [[self associatedValueForKey:@selector(pollingIsCancelled)] boolValue];
}

- (void)associateValue:(id)value withKey:(void*)key associationPolicy:(objc_AssociationPolicy)policy {
    objc_setAssociatedObject(self, key, value, policy);
}

- (id)associatedValueForKey:(void*)key {
    return objc_getAssociatedObject(self, key);
}

@end

#pragma mark - Social Interaction

@implementation PVideo (Social)

- (NSURL*)shareUrl {
    return (self.isNew) ? nil : [NSURL URLWithString:self.shareUrlString];
}

- (NSString*)openGraphObjectKey {
    return @"present";
}

- (NSMutableDictionary<FBOpenGraphObject>*)openGraphObject {
    // TODO: Move the NSString class method to a category
    return [FBGraphObject openGraphObjectForPostWithType:[NSString stringWithFormat:@"presenttv:%@", [self openGraphObjectKey]]
                                                   title:self.titleString
                                                   image:self.coverUrlString
                                                     url:self.shareUrl.absoluteString
                                             description:@""];
}

- (void)shareToFacebook {
    [PSocialManager showComposeControllerForAccountType:PSocialAccountTypeIdentifierFacebook
                                            withMessage:self.twitterShareString
                                                    url:self.shareUrl
                                                success:nil
                                                failure:nil];
}

- (void)postToFacebook {
    [PSocialManager postObjectToFacebook:self withAction:PFacebookShareActionVideoPost];
}

- (void)likeOnFacebook {
    [PSocialManager postObjectToFacebook:self withAction:PFacebookShareActionVideoLike];
}

- (void)shareToTwitter {
    [PSocialManager showComposeControllerForAccountType:PSocialAccountTypeIdentifierTwitter
                                            withMessage:self.twitterShareString
                                                    url:self.shareUrl
                                                success:nil
                                                failure:nil];
}

- (void)postToTwitter {
    [PSocialManager postObjectToTwitter:self withAction:PTwitterShareActionPost];
}

- (NSString*)titleString {
    return (self.isTitleValid) ? [NSString stringWithFormat:@"\"%@\"", self.title] : @"something";
}

- (NSString*)twitterShareString {
    return [NSString stringWithFormat:@"Check out %@ I found on Present! %@", self.titleString, self.shareUrl.absoluteString];
}

- (NSString*)twitterPostString {
    return [NSString stringWithFormat:@"I just started sharing %@ live on Present! %@", self.titleString, self.shareUrl.absoluteString];
}

- (NSString*)textMessageBody {
    return [NSString stringWithFormat:@"Hey, you should check out %@ on Present! %@", self.titleString, self.shareUrl.absoluteString];
}

- (NSString*)emailSubject {
    return @"You should check out this video from Present";
}

- (NSString*)emailBody {
    return [NSString stringWithFormat:@"I found this on Present and thought you might enjoy it. %@", self.shareUrl.absoluteString];
}

@end
