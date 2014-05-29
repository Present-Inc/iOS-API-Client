//
//  PActivity.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Networking.h"
#import "PObject+Subclass.h"

@class PUser;
@class PComment;
@class PVideo;
@class PUserResult;
@class PVideoResult;
@class PCommentResult;

typedef NS_ENUM(NSInteger, PActivityType) {
    PActivityTypeNewComment,
    PActivityTypeNewCommentMention,
    PActivityTypeNewDemand,
    PActivityTypeNewFollower,
    PActivityTypeNewLike,
    PActivityTypeNewVideoByDemandedUser,
    PActivityTypeNewVideoByFriend,
    PActivityTypeNewVideoMention,
    PActivityTypeNewViewer
};

@interface PActivity : PObject <PObjectSubclassing>

@property (nonatomic) PActivityType type;

@property (strong, nonatomic) PUserResult *fromUserResult;
@property (strong, nonatomic) PUserResult *toUserResult;
@property (strong, nonatomic) PCommentResult *commentResult;
@property (strong, nonatomic) PVideoResult *videoResult;

@property (strong, nonatomic) NSString *subject;

@property (nonatomic, getter = isUnread) BOOL unread;

@end

@interface PActivity (ResourceMethods)

+ (NSURLSessionDataTask*)getActivityForCurrentUserWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)saveActivityCollection:(NSArray*)collection success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

@end
