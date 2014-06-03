//
//  PResponseResult.h
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import "PSubjectiveObjectMeta.h"

@class PObject;
@class PActivity;
@class PComment;
@class PDemand;
@class PFriendship;
@class PLike;
@class PPlace;
@class PUser;
@class PUserContext;
@class PVideo;
@class PPlaylistSession;
@class PView;

@interface PResult : MTLModel <MTLJSONSerializing>
@property (strong, nonatomic) PSubjectiveObjectMeta *subjectiveObjectMeta;

- (id)object;

@end

@interface PActivityResult : PResult
@property (strong, nonatomic) PActivity *activity;
@end

@interface PCommentResult : PResult
@property (strong, nonatomic) PComment *comment;
@end

@interface PDemandResult : PResult
@property (strong, nonatomic) PDemand *demand;
@end

@interface PFriendshipResult : PResult
@property (strong, nonatomic) PFriendship *friendship;
@end

@interface PLikeResult : PResult
@property (strong, nonatomic) PLike *like;
@end

@interface PPlaceResult : PResult
@property (strong, nonatomic) PPlace *place;
@end

@interface PUserResult : PResult
@property (strong, nonatomic) PUser *user;

- (instancetype)initWithUser:(PUser*)user;
- (instancetype)initWithUser:(PUser*)user subjectiveObjectMeta:(PSubjectiveObjectMeta*)objectMeta;

@end

@interface PUserContextResult : PResult
@property (strong, nonatomic) PUserContext *userContext;
@end

@interface PVideoResult : PResult
@property (strong, nonatomic) PVideo *video;
@property (strong, nonatomic) PPlaylistSession *playlistSession;

- (instancetype)initWithVideo:(PVideo*)video;
- (instancetype)initWithVideo:(PVideo*)video subjectiveObjectMeta:(PSubjectiveObjectMeta*)objectMeta;

@end

@interface PViewResult : PResult
@property (strong, nonatomic) PView *view;
@end
