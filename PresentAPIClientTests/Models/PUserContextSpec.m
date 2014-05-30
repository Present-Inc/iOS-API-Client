//
//  PUserContextSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PUserContext.h"

#import "PUser.h"
#import "PResult.h"


SPEC_BEGIN(PUserContextSpec)

describe(@"PUserContext", ^{
    it (@"can authenticate a user with valid credentials", ^{
        __block PUserContext *fetchedContext = nil;
        __block NSError *responseError = nil;
        
        NSDictionary *credentials = @{
            @"username": @"test",
            @"password": @"itunesconnect001"
        };
        
        [PUserContext authenticateWithCredentials:credentials
                                          success:^(PUserContext *currentContext) {
                                              fetchedContext = currentContext;
                                          }failure:^(NSError *error) {
                                              responseError = error;
                                          }];
        
        [[fetchedContext shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
        [[fetchedContext shouldEventuallyBeforeTimingOutAfter(10.0)] beMemberOfClass:[PUserContext class]];
        
        [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
    });
    
    context(@"after authentication", ^{
        __block PUserContext *currentUserContext = nil;
        
        beforeAll(^{
            PUser *userMock = [PUser objectWithObjectId:@"666"];
            
            PUserResult *userResultMock = [[PUserResult alloc] init];
            userResultMock.user = userMock;
            
            currentUserContext = [PUserContext objectWithObjectId:@"789"];
            currentUserContext.userResult = userResultMock;
            currentUserContext.sessionToken = @"SliceMyPizza553!!@#";
            [PUserContext stub:@selector(currentContext) andReturn:currentUserContext];
        });
        
        afterAll(^{
            [PUserContext logOut];
            currentUserContext = nil;
        });
        
        it (@"can return the current user context", ^{
            PUserContext *currentContext = [PUserContext currentContext];
            [[currentContext should] equal:currentUserContext];
        });
    });
});

SPEC_END
