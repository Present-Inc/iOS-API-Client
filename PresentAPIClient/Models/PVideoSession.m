//
//  PVideoSession.m
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PVideoSession.h"

#import <PFileManager.h>

#import "PAPIManager.h"
#import "PVideoSegment.h"
#import "PVideo.h"
#import "PVideoSessionState.h"
#import "PVideoSessionMeta.h"
#import "PResult.h"

#import <NSObject+JSON.h>

@interface PVideoSession () {
    NSProgress *currentProgress;
    
    BOOL pendingVideoCreate;
}

@property (strong, nonatomic) PVideoSessionState *state;
@property (strong, nonatomic) PVideoSessionMeta *meta;

@property (copy, nonatomic) void(^createSuccessBlock)(PVideoSession *session);
@property (copy, nonatomic) void(^createFailureBlock)(NSError *error);

- (PAPIManager*)requestManager;

- (void)cancelUploadTasks;

- (BOOL)readyForAppend;
- (BOOL)finishedUploads;
- (BOOL)canUploadSegments;
- (BOOL)isVideoCreated;

- (NSURL*)stillImage;

- (PObjectResultBlock)createSuccess;
- (PFailureBlock)createFailure;

- (void(^)(id))successfulUpload;
- (void(^)(NSError *))failedUpload;

@end

const char *AppendSerializeLabel    = "tv.present.Present.networkCommunications.appendSerialization";

static NSString *videoIdKey         = @"video_id";
static NSString *mediaSequenceKey   = @"media_sequence";
static NSString *playlistSessionKey = @"playlist_session";
static NSString *mediaSegmentKey    = @"media_segment";

static NSInteger MaxRetryCount      = 3;

@implementation PVideoSession

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"createSuccessBlock": NSNull.null,
        @"createFailureBlock": NSNull.null,
        @"delegate": NSNull.null,
        @"uploadProgress": NSNull.null,
    };
}

+ (NSDictionary*)encodingBehaviorsByPropertyKey {
    NSMutableDictionary *behaviors = [NSMutableDictionary dictionaryWithCapacity:self.propertyKeys.count];
    [behaviors addEntriesFromDictionary:[super encodingBehaviorsByPropertyKey]];
    [behaviors removeObjectForKey:@"uploadProgress"];
    
    NSNumber *excluded = @(MTLModelEncodingBehaviorExcluded);
    NSDictionary *excludedBehaviors = @{
        @"createSuccessBlock": excluded,
        @"createFailureBlock": excluded,
        @"delegate": excluded,
    };
    
    [behaviors addEntriesFromDictionary:excludedBehaviors];
    return behaviors;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
}

+ (NSValueTransformer*)videoResultJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PVideoResult.class];
}

+ (NSValueTransformer*)playlistSessionJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PPlaylistSession.class];
}

+ (NSValueTransformer*)metaJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PVideoSessionMeta.class];
}

+ (NSValueTransformer*)stateJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PVideoSessionState.class];
}

+ (NSValueTransformer*)segmentsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:PVideoSegment.class];
}

+ (instancetype)sessionWithVideo:(PVideo *)video successBlock:(PObjectResultBlock)successBlock failureBlock:(PFailureBlock)failureBlock {
    NSLog(@"Creating a new session");
    PVideoSession *newSession = [[PVideoSession alloc] init];
    
    newSession.videoResult = [[PVideoResult alloc] init];
    newSession.videoResult.video = video;
    
    newSession.state.uploadOnWWAN = [PAPIManager sharedManager].isReachableViaWWAN;
    
    if (successBlock) {
        newSession.createSuccessBlock = [successBlock copy];
    }
    
    if (failureBlock) {
        newSession.createFailureBlock = [failureBlock copy];
    }
    
    return newSession;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        _meta = [[PVideoSessionMeta alloc] init];
        _state = [[PVideoSessionState alloc] init];
        _segments = [NSMutableArray array];
    }
    
    return self;
}

- (PAPIManager*)requestManager {
    return [PAPIManager sharedManager];
}

#pragma mark - Session Lifecycle

- (void)createSession {
    if (!pendingVideoCreate && self.video) {
        [self.video createWithSuccess:self.createSuccess failure:self.createFailure];
        pendingVideoCreate = YES;
    }
}

- (void)endSession {
    if (self.video.isLive) {
        [self.video endWithSuccess:nil failure:nil];
    }
    
    self.state.finished = YES;
}

- (void)finishSession {
    [self endSession];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(videoSessionDidFinish:)]) {
            [_delegate videoSessionDidFinish:self];
        }
    });
}

- (void)deleteVideo {
    [self cancelUploadTasks];
    if (self.isCreated) {
        [self.video delete];
        self.state.deleted = YES;
    }
}

- (void)cancelUploadTasks {
    [self.requestManager cancelTasksWithDescription:self.video._id];
}

-(void)appendFile:(NSURL *)target isLastSegment:(BOOL)lastSegment {
    if (lastSegment) {
        [self.video endWithSuccess:nil failure:nil];
    }
    
    self.state.shouldFinish = lastSegment;
    
    PVideoSegment *nextSegment = [PVideoSegment segment:target forMediaSequence:self.meta.fileNumber];
    [self addSegment:nextSegment];
    
    if (self.requestManager.isReachable) {
        if (!self.isCreated) {
            [self createSession];
        }else if (self.segments.count == 1) {
            [self appendNextSegment];
        }
    }
}

- (void)appendNextSegment {
    if (self.readyForAppend) {
        NSLog(@"Appending next segment");
        [self startAppendRequest];
    }else if (self.segments.count == 0 && !self.video.isLive) {
        NSLog(@"Ending session");
        [self endSession];
    }
}

- (void)startAppendRequest {
    PVideoSegment *segment = [self.segments firstObject];
    
    self.playlistSession.meta.shouldFinish = (!self.video.isLive && self.segments.count == 1) || (self.video.isLive && self.state.shouldFinish);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(videoSessionWillStartUpload:mediaSequence:)]) {
            [_delegate videoSessionWillStartUpload:self mediaSequence:segment.mediaSequence];
        }
    });
    
    NSDictionary *parameters = @{
        mediaSequenceKey: [NSNumber numberWithInteger:segment.mediaSequence],
        playlistSessionKey: [[MTLJSONAdapter JSONDictionaryFromModel:self.playlistSession] JSONString],
        videoIdKey: self.video._id
    };
    
    NSProgress *progress;
    [self.video appendSegment:segment
                   parameters:parameters
                     progress:&progress
                      success:self.successfulUpload
                      failure:self.failedUpload];
    /*
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:(NSKeyValueObservingOptionNew)
                  context:NULL];*/
}

#pragma mark Accessors

- (NSURL*)stillImage {
    return self.video.coverURL;
}

- (NSNumber*)uploadProgress {
    return @(currentProgress.fractionCompleted * 100);
}

- (BOOL)isFinished {
    return self.sessionFinished;
}

- (BOOL)finishedUploads {
    return (!self.video.isLive && self.meta.finishedUploads);
}

- (BOOL)readyForAppend {
    return (!self.sessionFinished && !self.state.isDeleted && self.segments.count > 0);
}

- (BOOL)sessionFinished {
//    PLog(@"Finished uploads: %@\nplaylistSession.meta.isFinished? %@\nDeleted? %@",
//         self.finishedUploads ? @"YES" : @"NO",
//         self.playlistSession.meta.isFinished ? @"YES" : @"NO",
//         self.state.isDeleted ? @"YES" : @"NO");
    
    return (self.finishedUploads && self.playlistSession.meta.isFinished) || (self.state.isDeleted);
}

- (BOOL)canUploadSegments {
    return (!self.video.isLive || (self.isCreated && !self.finishedUploads));
}

- (BOOL)isVideoCreated {
    return !!self.video._id;
}

- (BOOL)isSessionCreated {
    return !!self.playlistSession;
}

- (BOOL)isCreated {
    return (self.isVideoCreated && self.isSessionCreated);
}

- (PVideoResult*)videoResult {
    if (!_videoResult) {
        _videoResult = [[PVideoResult alloc] init];
    }
    
    return _videoResult;
}

- (PPlaylistSession*)playlistSession {
    return self.videoResult.playlistSession;
}

- (PVideo*)video {
    return self.videoResult.video;
}

#pragma mark Mutators

- (void)addSegment:(PVideoSegment*)segment {
    [self.segments addObject:segment];
    self.meta.fileNumber++;
}

- (void)deleteSegment:(PVideoSegment*)segment {
    [PFileManager deleteFileAtURL:segment.url];
    [self.segments removeObject:segment];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"Observe value of %@ in %@ with change %@ in context %@", keyPath, object, change, context);
}

#pragma mark - Blocks

- (PObjectResultBlock)createSuccess {
    return ^(PVideoResult *result) {
        NSLog(@"Successfully created video session");
        self.meta.createRetryCount = 0;
        
        [self.videoResult mergeValuesForKeysFromModel:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(videoSessionWasCreated:)]) {
                [_delegate videoSessionWasCreated:self];
            }
            
            if (self.createSuccessBlock) {
                self.createSuccessBlock(self);
            }
        });
        
        pendingVideoCreate = NO;
    };
}

- (PFailureBlock)createFailure {
    return ^(NSError *error) {
        NSLog(@"Failed to create video session");
        self.meta.createRetryCount++;
        
        if (self.meta.createRetryCount < MaxRetryCount) {
            [self createSession];
        }else {
            self.meta.createRetryCount = 0;
            
            if (self.createFailureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.createFailureBlock(error);
                });
            }
        }
        
        pendingVideoCreate = NO;
    };
}

- (void(^)(id))successfulUpload {
    return ^(PVideoResult *videoResult) {
        [self.playlistSession mergeValuesForKeysFromModel:videoResult.playlistSession];
        
        PVideoSegment *segment = [self.segments firstObject];
        [self deleteSegment:segment];
        
        self.meta.completedUploads++;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(videoSessionDidCompleteUpload:mediaSequence:)]) {
                [_delegate videoSessionDidCompleteUpload:self mediaSequence:segment.mediaSequence];
            }
        });
        
        if (self.sessionFinished) {
            [self finishSession];
        }else if (self.canUploadSegments) {
            [self appendNextSegment];
        }
    };
}

- (void(^)(NSError *))failedUpload {
    return ^(NSError *error) {
        PErrorResponse *errorObject = error.userInfo[PErrorResponseKey];
        PVideoSegment *segment = [self.segments firstObject];
        
        if (segment.retryCount == MaxRetryCount) {
            NSLog(@"Segment has reached max retry count");
            segment.retryCount = 0;
            return;
        }else if (errorObject.code == PErrorCodeVideoAppendConversionError) {
            NSLog(@"Append failed. Deleting");
            [self deleteSegment:segment];
            self.meta.failedUploads++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(videoSessionDidDeleteSegment:)]) {
                    [_delegate videoSessionDidDeleteSegment:segment];
                }
            });
        }else {
            NSLog(@"Upload failed or unknown error, retry");
            segment.retryCount++;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(videoSessionDidFailUpload:mediaSequence:withError:)]) {
                [_delegate videoSessionDidFailUpload:self mediaSequence:segment.mediaSequence withError:error];
            }
        });
        
        [self appendNextSegment];
    };
}

@end
