//
//  PNetworkCommunications.m
//  Present
//
//  Created by Justin Makaila on 9/21/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PVideoSessionManager.h"

#import <FBKVOController.h>

#import "PAPIManager.h"

#import "PVideo.h"
#import "PVideoSession.h"
#import "PVideoSegment.h"

typedef void (^ConstructingBlock)(id<AFMultipartFormData>);

NSString *const PNetworkClientDidStartNotification  = @"PNetworkClientDidStartNotification";
NSString *const PNetworkClientDidEndNotification    = @"PNetworkClientDidEndNotification";
NSString *const PNetworkClientDidFinishPostingFile  = @"PNetworkClientDidFinishPostingFile";
NSString *const PNetworkClientDidFailWithError      = @"PNetworkClientDidFailWithError";
NSString *const PNetworkClientRequireUserPermission = @"PNetworkClientRequireUserPermission";

@interface PVideoSessionManager() <PVideoSessionDelegate>

@property (strong, nonatomic) NSMutableArray *sessions;
@property (strong, nonatomic) PVideoSession *currentSession;

@property (nonatomic) BOOL paused;

- (void)applicationWillEnterForeground;

@end

static NSString *SavedSessionDataPath = @"PSessionData";

/**
 *  Singleton object for managing video uploads
 */
@implementation PVideoSessionManager

/**
 *  Returns a singleton network client
 *
 *  @return Singleton PNetworkCommunications object
 */
+ (instancetype)sharedManager {
    static dispatch_once_t pred;
    static PVideoSessionManager *_videoSessionManager = nil;
    
    dispatch_once(&pred, ^{
        _videoSessionManager = [[PVideoSessionManager alloc] init];
    });
    
    return _videoSessionManager;
}

/**
 *  Initializes the PNetworkCommunications object
 *  with default values
 *
 *  @return An instance of PNetworkCommunications
 */
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.sessions = [self loadSessions];
        if (!self.sessions) {
            self.sessions = [NSMutableArray array];
        }else {
            [self checkPendingSessions];
        }
    }
    
    return self;
}

- (void)reachabilityChanged:(NSNotification*)notification {
    if (notification) {
        if (![PAPIManager sharedManager].isReachable) {
            [self pauseManager];
        }else {
            [self resumeManager];
        }
    }
}

/**
 *  Called when the application did enter background. Saves the
 *  session state
 */
- (void)shutdown {
    for (PVideoSession *session in self.sessions) {
        [session endSession];
    }
    
    [self saveSessions];
}

#pragma mark - Observation

- (void)applicationWillEnterForeground {
    [self checkPendingSessions];
}

#pragma mark - Sessions

/**
 *  Makes sure that the network is reachable by WiFi and resumes
 *  uploading sessions, else posts a notification to prompt for
 *  user permission
 */
- (void)checkPendingSessions {
    if (self.sessions.count > 0 && !self.paused) {
        PAPIManager *manager = [PAPIManager sharedManager];
        
        if (manager.isReachableViaWiFi || self.currentSession.state.shouldUploadOnWWAN) {
            [self resumeSessions];
        }else if (manager.isReachableViaWWAN && !self.currentSession.state.shouldUploadOnWWAN) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PNetworkClientRequireUserPermission object:self.currentSession];
        }
    }
}

- (void)appendFile:(NSURL *)target isLastSegment:(BOOL)lastSegment {
    [self.currentSession appendFile:target isLastSegment:lastSegment];
}

/**
 *  Called to grant access to upload the current session on WWAN
 *
 *  @param granted Is access granted?
 */
- (void)uploadOnWWANGranted:(BOOL)granted {
    self.currentSession.state.uploadOnWWAN = granted;
    
    if (granted) {
        [self resumeSessions];
    }
}

/**
 *  Retries the current session
 */
- (void)retryCurrentSession {
    [self resumeSessions];
}

/**
 *  Cancels the current session
 */
- (void)cancelCurrentSession {
    if (self.currentSession) {
        [self.currentSession endSession];
        [self.currentSession deleteVideo];
    }
}

/**
 *  Checks sessions to start/resume the upload process
 */
- (void)resumeSessions {
    FunctionLog();
    @synchronized(self) {
        if (self.sessions.count > 0) {
            if (self.currentSession.isFinished || (!self.currentSession.video.isLive && self.currentSession.segments.count == 0) || !self.currentSession.video) {
                [self.sessions removeObject:_currentSession];
                _currentSession = nil;
                return [self resumeSessions];
            }
            
            if (!self.currentSession) {
                return;
            }
            
            if (!self.currentSession.isCreated) {
                return [self.currentSession createSession];
            }else if (self.currentSession.segments.count > 0) {
                return [self.currentSession appendNextSegment];
            }else if (!self.currentSession.video.isLive) {
                return [self.currentSession endSession];
            }
        }
    }
}

- (void)pauseSessions {
    FunctionLog();
}

- (void)pauseManager {
    self.paused = YES;
}

- (void)resumeManager {
    self.paused = NO;
    
    [self checkPendingSessions];
    
    self.currentSession.state.uploadOnWWAN = self.shouldUploadOnWWAN;
}

/**
 *  Returns the current session
 *
 *  @return If no current session, returns the first object in the sessions
 *  array
 */
- (PVideoSession*)currentSession {
    if (!_currentSession) {
        _currentSession = [self.sessions firstObject];
        
        [_currentSession.segments enumerateObjectsUsingBlock:^(PVideoSegment *segment, NSUInteger index, BOOL __unused *shouldStop) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:segment.url.path]) {
                [_currentSession.segments removeObjectAtIndex:index];
                _currentSession.meta.fileNumber--;
            }
        }];
        
        _currentSession.delegate = self;
    }
    
    return _currentSession;
}

#pragma mark - Session Lifecycle

- (void)createVideo:(PVideo *)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    _currentSession = nil;
    PVideoSession *session = [PVideoSession sessionWithVideo:video successBlock:success failureBlock:failure];
    
    [self.sessions insertObject:session atIndex:0];
    
    if ([PAPIManager sharedManager].isReachable) {
        [self checkPendingSessions];
    }
}

/**
 *  Saves all sessions to the documents directory
 *
 *  @return Boolean indicating whether or not the save
 *  was successful
 */
- (BOOL)saveSessions {
    NSString *savedSessionPath = [PFileManager pathToFile:SavedSessionDataPath inSearchPathDirectory:NSDocumentDirectory];
    
    if ([PFileManager fileExistsAtPath:savedSessionPath]) {
        [PFileManager deleteFileAtPath:savedSessionPath];
    }
    
    if (self.sessions.count > 0) {
        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:self.sessions];
        return [PFileManager createFileAtPath:savedSessionPath withData:sessionData];
    }else {
        return NO;
    }
}

- (BOOL)shouldUploadOnWWAN {
    return (self.currentSession.video.isLive && [PAPIManager sharedManager].isReachableViaWWAN);
}

- (BOOL)isRunning {
    return (self.sessions.count > 0) && (self.currentSession.segments.count > 0);
}

- (NSNumber*)jobCount {
    return @(self.sessions.count);
}

/**
 *  Loads an existing session from the documents directory
 *
 *  @return A dictionary containing any pending uploads
 */
- (NSMutableArray*)loadSessions {
    NSString *savedSessionPath = [PFileManager pathToFile:SavedSessionDataPath inSearchPathDirectory:NSDocumentDirectory];
    
    if ([PFileManager fileExistsAtPath:savedSessionPath]) {
        NSData *sessionData = [NSData dataWithContentsOfFile:savedSessionPath];
        return [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
    }else {
        return nil;
    }
}

- (NSNumber*)totalProgress {
    return [NSNumber numberWithDouble:(self.currentSession.uploadProgress.floatValue / self.sessions.count)];
}

#pragma mark - PVideoSessionDelegate

- (void)videoSessionWasCreated:(PVideoSession *)session {
    NSLog(@"Session was created successfully");
    [self checkPendingSessions];
}

- (void)videoSessionDidSkipSegment:(PVideoSegment*)segment {
    NSLog(@"Segment did not exist!");
    [self checkPendingSessions];
}

- (void)videoSessionWillStartUpload:(PVideoSession *)session mediaSequence:(NSInteger)mediaSequence {
    NSLog(@"Session will start upload of sequence %li", (long)mediaSequence);
}

- (void)videoSessionDidCompleteUpload:(PVideoSession *)session mediaSequence:(NSInteger)mediaSequence {
    NSLog(@"Session did complete upload of sequence %li", (long)mediaSequence);
    [self saveSessions];
    
    [[Mixpanel sharedInstance] track:@"Successful Video Segment Upload" properties:@{
        @"Media Sequence": @(mediaSequence),
        @"Session": [MTLJSONAdapter JSONDictionaryFromModel:session]
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PNetworkClientDidFinishPostingFile object:session];
}

- (void)videoSessionDidFailUpload:(PVideoSession*)session mediaSequence:(NSInteger)mediaSequence withError:(NSError*)error {
    NSLog(@"Session did fail upload of sequence %li", (long)mediaSequence);
    ErrorLog(error);
    
    [self checkPendingSessions];
    
    [[Mixpanel sharedInstance] track:@"Failed Video Segment Upload" properties:@{
        @"Media Sequence": @(mediaSequence),
        @"Session": [MTLJSONAdapter JSONDictionaryFromModel:session],
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PNetworkClientDidFailWithError object:error];
}

- (void)videoSessionDidFinish:(PVideoSession *)session {
    NSLog(@"Session did finish");
    [self.sessions removeObject:session];
    
    if ([self.currentSession isEqual:session]) {
        _currentSession = nil;
    }
    
    if (session.isCreated && !session.state.isDeleted) {
        [[Mixpanel sharedInstance] track:@"Video Create" properties:@{
            @"Start Time": session.video.startTime,
            @"End Time": session.video.endTime,
            @"Video ID": session.video._id
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PNetworkClientDidEndNotification object:nil];
    
    [self saveSessions];
    [self checkPendingSessions];
}

@end
