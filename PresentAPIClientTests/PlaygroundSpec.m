//
//  PlaygroundSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "PObject.h"
#import "PUser+SubjectiveObjectMeta.h"
#import "PResult.h"
#import "PRelationship.h"


SPEC_BEGIN(PlaygroundSpec)

describe(@"Playground", ^{
    it (@"can handle a collection response by extracting all the models and updating the cursor", ^{
        PUser *currentUserMock = [PUser object];
        currentUserMock.clientId = @"666";
        
        [PUser stub:@selector(currentUser) andReturn:currentUserMock];
        [[[PUser currentUser] should] equal:currentUserMock];
        
        // Set up sample results
        NSMutableArray *results = [NSMutableArray array];
        PRelation *friendshipRelation = [PRelation relationForward:YES backward:NO];
        for (NSInteger i = 0; i < 30; i++) {
            PUserResult *userResult = [[PUserResult alloc] init];
            
            PUser *user = [PUser objectWithObjectId:@"tyu789"];
            
            userResult.user = user;
            userResult.subjectiveObjectMeta = [[PSubjectiveObjectMeta alloc] init];
            userResult.subjectiveObjectMeta.friendship = friendshipRelation;
            
            [results addObject:userResult];
        }
        
        // Set up current cursor and items array
        __block NSInteger currentCursor = 0;
        __block NSMutableArray *items = [NSMutableArray array];
        __block void (^success) (NSArray *, NSInteger) = ^(NSArray *results, NSInteger nextCursor) {
            [[theValue([results count]) should] equal:@30];
            [[theValue(nextCursor) should] equal:@30];
        };
        
        void (^collectionResultsBlock) (NSArray *, NSInteger) = ^(NSArray *results, NSInteger nextCursor) {
            if (currentCursor == 0) {
                [items removeAllObjects];
            }
            
            for (PResult *result in results) {
                [items addObject:result.object];
                [[PUser currentUser] addSubjectiveRelationshipsForResult:result];
            }
            
            if (success) {
                success(items, nextCursor);
            }
            
            currentCursor = nextCursor;
        };
        
        collectionResultsBlock(results, 30);
    });
});

SPEC_END
