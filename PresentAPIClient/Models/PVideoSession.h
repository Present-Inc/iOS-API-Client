//
//  PVideoSession.h
//  Present
//
//  Created by Justin Makaila on 1/10/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Mantle.h>

#import "PPlaylistSession.h"
#import "PVideoSessionState.h"
#import "PVideoSessionMeta.h"
#import "PAPIManager.h"

@class PVideoSegment;
@class PVideoSession;
@class PVideo;
@class PVideoResult;

@protocol PVideoSessionDelegate <NSObject>
- (void)videoSessionWasCreated:(PVideoSession*)session;

- (void)videoSessionDidFinish:(PVideoSession*)session;

- (void)videoSessionDidDeleteSegment:(PVideoSegment*)segment;

- (void)videoSessionWillStartUpload:(PVideoSession*)session mediaSequence:(NSInteger)mediaSequence;

- (void)videoSessionDidCompleteUpload:(PVideoSession*)session mediaSequence:(NSInteger)mediaSequence;
- (void)videoSessionDidFailUpload:(PVideoSession*)session mediaSequence:(NSInteger)mediaSequence withError:(NSError*)error;
@end

@interface PVideoSession : MTLModel <MTLJSONSerializing>

@property (weak, nonatomic) id<PVideoSessionDelegate> delegate;

@property (strong, nonatomic) PVideoResult *videoResult;

@property (strong, nonatomic) NSNumber *uploadProgress;
@property (strong, nonatomic) NSMutableArray *segments;

@property (readonly, strong, nonatomic) PVideoSessionState *state;
@property (readonly, strong, nonatomic) PVideoSessionMeta *meta;

+ (instancetype)sessionWithVideo:(PVideo*)video successBlock:(PObjectResultBlock)successBlock failureBlock:(PFailureBlock)failureBlock;

- (void)createSession;

- (void)appendFile:(NSURL *)target isLastSegment:(BOOL)lastSegment;
- (void)appendNextSegment;

- (void)endSession;

- (PVideo*)video;
- (PPlaylistSession*)playlistSession;

- (void)deleteVideo;

- (BOOL)isCreated;
- (BOOL)isFinished;

@end
