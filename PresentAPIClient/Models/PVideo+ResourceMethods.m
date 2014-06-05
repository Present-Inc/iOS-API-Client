//
//  PVideo+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Networking.h"
#import "PVideo+ResourceMethods.h"

#import <objc/runtime.h>

#import "PUser+ResourceMethods.h"
#import "PComment+ResourceMethods.h"
#import "PLike+ResourceMethods.h"
#import "PPlace+ResourceMethods.h"
#import "PLocation.h"
#import "PResult.h"
#import "PRelationship.h"
#import "PVideoSegment.h"
#import "PPlaylistSession.h"

#import <NSArray+Convenience.h>

static NSString *videoIdKey         = @"video_id";
static NSString *mediaSequenceKey   = @"media_sequence";
static NSString *playlistSessionKey = @"playlist_session";
static NSString *mediaSegmentKey    = @"media_segment";

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
        if (self.likesCursor == 0) {
            [self.likesArray removeAllObjects];
        }
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:results.count];
        for (PLikeResult *result in results) {
            PUser *user = result.like.sourceUser;
            [users addObject:user];
        }
        
        [self.likesArray addObjectsFromArray:users];
        
        if (success) {
            success(results, nextCursor);
        }
        
        self.likesCursor = nextCursor;
    };
    
    return [PLike getLikesForVideo:self
                           success:successBlock
                           failure:failure];
}

- (NSURLSessionDataTask*)getCommentsWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.commentsCursor == 0) {
            [self.commentsArray removeAllObjects];
        }
        
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:results.count];
        for (PCommentResult *result in results) {
            PComment *comment = result.comment;
            
            comment.targetVideoResult = [[PVideoResult alloc] init];
            comment.targetVideoResult.video = self;
            comment.targetVideoResult.subjectiveObjectMeta.like = [PUser currentUser].likes.get(self);
            
            [comments addObject:comment];
        }
        
        [self.commentsArray addObjectsFromArray:[comments sortedArray]];
        
        if (success) {
            success(results, nextCursor);
        }
        
        self.commentsCursor = nextCursor;
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

