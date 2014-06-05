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

@class MKMapView;

@interface PVideo : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *creatorUserResult;

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
- (void)end;

- (NSArray*)mostRecentComments;
- (PUser*)creatorUser;

- (CLLocationCoordinate2D)coordinate;

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
