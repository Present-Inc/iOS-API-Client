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
    it (@"can log a user in with username and password", ^{
        __block PUser *loggedInUser = nil;
        __block NSError *responseError = nil;
        
        [PUser loginWithUsername:@"justin" password:@"Underoath1" success:^(PUser *user) {
            loggedInUser = user;
        }failure:^(NSError *error) {
            responseError = error;
        }];
        
        [[loggedInUser shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
        [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
    });
});

SPEC_END
