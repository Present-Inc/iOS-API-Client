//
//  PUserSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PUser.h"


SPEC_BEGIN(PUserSpec)

describe(@"PUser", ^{
    __block PUser *loggedInUser = nil;
    __block NSError *responseError = nil;
    
    context(@"login", ^{
        beforeEach(^{
            loggedInUser = nil;
        });
        
        afterAll(^{
            loggedInUser = nil;
            responseError = nil;
        });
        
        it (@"can log a user in with username and password", ^{
            [PUser stub:@selector(loginWithUsername:password:success:failure:) withBlock:^id (NSArray *params) {
                PObjectResultBlock successBlock = params[2];
                successBlock([PUser mock]);
                
                return nil;
            }];
            
            [PUser loginWithUsername:@"test" password:@"itunesconnect001" success:^(PUser *user) {
                loggedInUser = user;
            }failure:^(NSError *error) {
                responseError = error;
            }];
            
            [[loggedInUser shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
            [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
        });
        
        it (@"can reject a user if the username or password is incorrect", ^{
            [PUser stub:@selector(loginWithUsername:password:success:failure:) withBlock:^id (NSArray *params) {
                PFailureBlock failureBlock = params[3];
                failureBlock([NSError mock]);
                
                return nil;
            }];
            
            [PUser loginWithUsername:@"test" password:@"thisisthewrongpassword" success:^(PUser *user) {
                loggedInUser = user;
            }failure:^(NSError *error) {
                responseError = error;
            }];
            
            [[loggedInUser shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
            [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
        });
    });
    
    context (@"after authentication", ^{
        beforeAll(^{
            [PUser loginWithUsername:@"test" password:@"itunesconnect001" success:^(PUser *user) {
                loggedInUser = user;
            }failure:^(NSError *error) {
                responseError = error;
            }];
            
            [[loggedInUser shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
            [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
        });
        
        beforeEach(^{
            responseError = nil;
        });
        
        it (@"can fetch itself", ^{
            __block PUser *fetchedUser = nil;
            
            [PUser getCurrentUserWithSuccess:^(PUser *currentUser) {
                fetchedUser = currentUser;
            }failure:^(NSError *error) {
                responseError = error;
            }];
            
            [[fetchedUser shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
            [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
        });    
    });
});

SPEC_END
