//
//  PUser+SubjectiveObjectMetaSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PUser+SubjectiveObjectMeta.h"

#import "PResult.h"
#import "PActivity.h"
#import "PVideo.h"
#import "PRelation.h"
#import "PRelationship.h"


SPEC_BEGIN(PUser_SubjectiveObjectMetaSpec)

describe(@"PUser+SubjectiveObjectMeta", ^{
    __block PUser *currentUserMock = nil;
    
    beforeAll(^{
        currentUserMock = [PUser object];
        currentUserMock.clientId = @"666";
    });
    
    afterAll(^{
        currentUserMock = nil;
    });
    
    context(@"PActivityResult", ^{
        __block PActivity *activityMock = nil;
        __block PUser *sourceUserMock = nil;
        __block PSubjectiveObjectMeta *sourceUserSubjectiveMeta = nil;
        __block PUserResult *sourceUserResultMock = nil;
        __block PActivityResult *activityResultMock = nil;
        
        beforeEach(^{
            sourceUserMock = [PUser mock];
            [sourceUserMock stub:@selector(_id) andReturn:@"abcd"];
            
            sourceUserSubjectiveMeta = [[PSubjectiveObjectMeta alloc] init];
            sourceUserSubjectiveMeta.friendship = [PRelation relationForward:YES backward:YES];
            
            sourceUserResultMock = [[PUserResult alloc] init];
            sourceUserResultMock.user = sourceUserMock;
            sourceUserResultMock.subjectiveObjectMeta = sourceUserSubjectiveMeta;
            
            activityMock = [PActivity mock];
            [activityMock stub:@selector(sourceUserResult) andReturn:sourceUserResultMock];
            
            activityResultMock = [PActivityResult mock];
            [activityResultMock stub:@selector(activity) andReturn:activityMock];
            
            [PUser stub:@selector(currentUser) andReturn:currentUserMock];
            [[[PUser currentUser] should] equal:currentUserMock];
            
            currentUserMock.friendships.clear();
        });
        
        afterEach(^{
            sourceUserMock = nil;
            sourceUserSubjectiveMeta = nil;
            sourceUserResultMock = nil;
            activityMock = nil;
        });
        
        it (@"can handle the relationships for PActivity result source user", ^{
            [activityMock stub:@selector(type) andReturn:theValue(PActivityTypeNewFollower)];
            [[theValue(activityMock.type) should] equal:theValue(PActivityTypeNewFollower)];
            
            // The current user should not follow the source user, nor should the
            // source user follow the current user
            [[theValue([PUser currentUser].friendships.to(sourceUserMock)) should] beNo];
            [[theValue([PUser currentUser].friendships.from(sourceUserMock)) should] beNo];
            
            // Add relationships for the activity result
            [[PUser currentUser] addSubjectiveRelationshipsForResult:activityResultMock];
            
            // The current user should not follow the source user, but the source user
            // should follow the current user
            [[theValue([PUser currentUser].friendships.to(sourceUserMock)) should] beYes];
            [[theValue([PUser currentUser].friendships.from(sourceUserMock)) should] beYes];
        });
        
        it (@"can handle the relationships for PActivityResult source user and video", ^{
            /**
             *  In this scenario, the user has already liked a friends video, but launched
             *  the app with the notification.
             */
            
            PVideo *videoMock = [PVideo mock];
            [videoMock stub:@selector(_id) andReturn:@"defgh"];
            [videoMock stub:@selector(creatorUser) andReturn:sourceUserResultMock];
            
            PRelation *likeRelation = [PRelation relationForward:YES backward:NO];
            
            PSubjectiveObjectMeta *videoObjectMeta = [[PSubjectiveObjectMeta alloc] init];
            videoObjectMeta.like = likeRelation;
            
            PVideoResult *videoResultMock = [PVideoResult mock];
            [videoResultMock stub:@selector(video) andReturn:videoMock];
            [videoResultMock stub:@selector(subjectiveObjectMeta) andReturn:videoObjectMeta];
            
            [activityMock stub:@selector(type) andReturn:theValue(PActivityTypeNewVideoByFriend)];
            [activityMock stub:@selector(videoResult) andReturn:videoResultMock];
            
            [[theValue(activityMock.type) should] equal:theValue(PActivityTypeNewVideoByFriend)];
            
            PUser *user = [PUser currentUser];
            NSLog(@"%@", user);
            
            // The current user should not follow the source user, nor should the
            // source user follow the current user
            [[theValue([PUser currentUser].friendships.to(sourceUserMock)) should] beNo];
            [[theValue([PUser currentUser].friendships.from(sourceUserMock)) should] beNo];
            
            // The current user should not like the target video (Yet).
            [[theValue([PUser currentUser].likes.to(videoMock)) should] beNo];
            
            [[PUser currentUser] addSubjectiveRelationshipsForResult:activityResultMock];
            
            [[theValue([PUser currentUser].likes.to(videoMock)) should] beYes];
            
            [[theValue([PUser currentUser].friendships.to(sourceUserMock)) should] beYes];
            [[theValue([PUser currentUser].friendships.from(sourceUserMock)) should] beYes];
        });
    });
});

SPEC_END
