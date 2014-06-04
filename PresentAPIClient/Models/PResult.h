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

- (instancetype)initWithSubjectiveObjectMeta:(PSubjectiveObjectMeta*)objectMeta;

- (PObject*)object;

@end

@interface PActivityResult : PResult
@property (strong, nonatomic) PActivity *activity;

- (instancetype)initWithActivity:(PActivity *)activity;
- (instancetype)initWithActivity:(PActivity *)activity subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PCommentResult : PResult
@property (strong, nonatomic) PComment *comment;

- (instancetype)initWithComment:(PComment *)comment;
- (instancetype)initWithComment:(PComment *)comment subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PDemandResult : PResult
@property (strong, nonatomic) PDemand *demand;

- (instancetype)initWithDemand:(PDemand *)demand;
- (instancetype)initWithDemand:(PDemand *)demand subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PFriendshipResult : PResult
@property (strong, nonatomic) PFriendship *friendship;

- (instancetype)initWithFriendship:(PFriendship *)friendship;
- (instancetype)initWithFriendship:(PFriendship *)friendship subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PLikeResult : PResult
@property (strong, nonatomic) PLike *like;

- (instancetype)initWithLike:(PLike *)like;
- (instancetype)initWithLike:(PLike *)like subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PPlaceResult : PResult
@property (strong, nonatomic) PPlace *place;

- (instancetype)initWithPlace:(PPlace *)place;
- (instancetype)initWithPlace:(PPlace *)place subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PUserResult : PResult
@property (strong, nonatomic) PUser *user;

- (instancetype)initWithUser:(PUser *)user;
- (instancetype)initWithUser:(PUser *)user subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PUserContextResult : PResult
@property (strong, nonatomic) PUserContext *userContext;

- (instancetype)initWithUserContext:(PUserContext *)userContext;
- (instancetype)initWithUserContext:(PUserContext *)userContext subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

@interface PVideoResult : PResult
@property (strong, nonatomic) PVideo *video;
@property (strong, nonatomic) PPlaylistSession *playlistSession;

- (instancetype)initWithVideo:(PVideo *)video;
- (instancetype)initWithVideo:(PVideo *)video subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end

// !!!: This is damn near deprecated.
@interface PViewResult : PResult
@property (strong, nonatomic) PView *view;

- (instancetype)initWithView:(PView *)view;
- (instancetype)initWithView:(PView *)view subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta;

@end
