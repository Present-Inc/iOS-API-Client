//
//  PActivity.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

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

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PUserResult *targetUserResult;
@property (strong, nonatomic) PCommentResult *commentResult;
@property (strong, nonatomic) PVideoResult *videoResult;

@property (strong, nonatomic) NSString *subject;

@property (nonatomic, getter = isUnread) BOOL unread;

- (PUser*)sourceUser;
- (PUser*)targetUser;

- (PVideo*)video;
- (PComment*)comment;

@end
