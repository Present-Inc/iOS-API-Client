//
//  PUser+SubjectiveObjectMeta.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser+SubjectiveObjectMeta.h"

#import "PSubjectiveObjectMeta.h"

#import "PResult.h"
#import "PActivity.h"
#import "PComment.h"
#import "PDemand.h"
#import "PFriendship.h"
#import "PLike.h"
#import "PPlace.h"
#import "PUserContext.h"
#import "PVideo.h"
#import "PView.h"
#import "PRelation.h"
#import "PRelationship.h"

@implementation PUser (SubjectiveObjectMeta)

- (void)addSubjectiveRelationshipsForResult:(PResult*)result {
    if ([result isMemberOfClass:[PActivityResult class]]) {
        PActivity *activity = ((PActivityResult*)result).activity;
        
        /**
         *  Handle the source user result of the activity
         */
        [self addSubjectiveRelationshipsForResult:activity.sourceUserResult];
        
        /**
         *  If the activity type is for a video, handle the video result
         *  Default, do nothing
         */
        switch (activity.type) {
            case PActivityTypeNewVideoByDemandedUser:
            case PActivityTypeNewVideoByFriend:
            case PActivityTypeNewVideoMention:
                [self addSubjectiveRelationshipsForResult:activity.videoResult];
                break;
            default:
                break;
        }
    }else if ([result isMemberOfClass:[PCommentResult class]]) {
        PComment *comment = ((PCommentResult*)result).comment;
        
        /**
         *  Handle the source user result.
         */
        [self addSubjectiveRelationshipsForResult:comment.sourceUserResult];
        
        /**
         *  Handle the target video result.
         */
        [self addSubjectiveRelationshipsForResult:comment.targetVideoResult];
    }else if ([result isMemberOfClass:[PDemandResult class]]) {
        PDemand *demand = ((PDemandResult*)result).demand;
        
        /**
         *  Handle the source user result.
         */
        [self addSubjectiveRelationshipsForResult:demand.sourceUserResult];
        
        /**
         *  Handle the target user result.
         */
        [self addSubjectiveRelationshipsForResult:demand.targetUserResult];
    }else if ([result isMemberOfClass:[PFriendshipResult class]]) {
        PFriendship *friendship = ((PFriendshipResult*)result).friendship;
        
        /**
         *  Handle the source user result.
         */
        [self addSubjectiveRelationshipsForResult:friendship.sourceUserResult];
        
        /**
         *  Handle the target user result.
         */
        [self addSubjectiveRelationshipsForResult:friendship.targetUserResult];
    }else if ([result isMemberOfClass:[PLikeResult class]]) {
        PLike *like = ((PLikeResult*)result).like;
        
        /**
         *  Handle the source user result.
         */
        [self addSubjectiveRelationshipsForResult:like.sourceUserResult];
        
        /**
         *  Handle the target video result.
         */
        [self addSubjectiveRelationshipsForResult:like.targetVideoResult];
    }else if ([result isMemberOfClass:[PUserResult class]]) {
        PUserResult *userResult = (PUserResult*)result;
        
        /**
         *  If the user is not equal to the current user, update the
         *  relationships.
         */
        if (![userResult.user isEqual:[PUser currentUser]]) {
            [self addSubjectiveRelationships:userResult.subjectiveObjectMeta forObject:userResult.user];
        }
    }else if ([result isMemberOfClass:[PVideoResult class]]) {
        PVideoResult *videoResult = (PVideoResult*)result;
        PVideo *video = videoResult.video;
        
        /**
         *  Update the relationships for the video
         */
        [self addSubjectiveRelationships:videoResult.subjectiveObjectMeta forObject:video];
        
        /**
         *  Handle the creator user result
         */
        [self addSubjectiveRelationshipsForResult:video.creatorUser];
    }else {
        return;
    }
}

- (void)addSubjectiveRelationships:(PSubjectiveObjectMeta *)objectMeta forObject:(PObject*)object {
    PRelation *friendship = objectMeta.friendship;
    PRelation *demand = objectMeta.demand;
    PRelation *like = objectMeta.like;
    
    if (friendship) {
        [PUser currentUser].friendships.set(object, friendship);
    }
    
    if (demand) {
        [PUser currentUser].demands.set(object, demand);
    }
    
    if (like) {
        [PUser currentUser].likes.set(object, like);
    }
}

@end
