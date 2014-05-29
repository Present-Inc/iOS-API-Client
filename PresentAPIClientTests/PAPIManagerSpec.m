//
//  PAPIManagerSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/27/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PAPIManager.h"
#import "PUserContext.h"
#import "PResult.h"
#import "PUser.h"

SPEC_BEGIN(PAPIManagerSpec)

describe(@"PAPIManager", ^{
    
    context(@"Setting HTTP Headers", ^{
        __block id userMock;
        __block id userResultMock;
        __block id userContextMock;
        
        beforeEach(^{
            userMock = [PUser mock];
            [[userMock should] receive:@selector(_id) andReturn:@"123456"];
            
            userResultMock = [PUserResult mock];
            [[userResultMock should] receive:@selector(user) andReturn:userMock];
            
            userContextMock = [PUserContext mock];
            [[userContextMock should] receive:@selector(userResult) andReturn:userResultMock];
            [[userContextMock should] receive:@selector(sessionToken) andReturn:@"78910"];
        });
        
        afterEach(^{
            userMock = nil;
            userResultMock = nil;
            userContextMock = nil;
        });
        
        it (@"can set the user context HTTP headers", ^{
            PAPIManager *manager = [PAPIManager sharedManager];
            [manager setUserContext:userContextMock];
            
            NSDictionary *requestHeaders = [manager.requestSerializer HTTPRequestHeaders];
            [[requestHeaders[@"Present-User-Context-User-Id"] should] equal:@"123456"];
            [[requestHeaders[@"Present-User-Context-Session-Token"] should] equal:@"78910"];
        });
        
        it (@"can clear the user context HTTP headers", ^{
            PAPIManager *manager = [PAPIManager sharedManager];
            [manager setUserContext:userContextMock];
            
            NSDictionary *requestHeaders = [manager.requestSerializer HTTPRequestHeaders];
            [[requestHeaders[@"Present-User-Context-User-Id"] should] equal:@"123456"];
            [[requestHeaders[@"Present-User-Context-Session-Token"] should] equal:@"78910"];
            
            [manager clearUserContext];
            requestHeaders = [manager.requestSerializer HTTPRequestHeaders];
            
            [[requestHeaders[@"Present-User-Context-User-Id"] should] beNil];
            [[requestHeaders[@"Present-User-Context-Session-Token"] should] beNil];
        });
    });
    
    it (@"can GET a collection from the API", ^{
        __block NSMutableArray *fetchedResults = nil;
        __block NSInteger currentCursor = 0;
        __block NSError *responseError = nil;
        
        NSURLSessionDataTask *task = [[PAPIManager sharedManager] getCollectionAtResource:@"videos/list_brand_new_videos"
                                                                           withParameters:@{}
                                                                                  success:^(NSArray *results, NSInteger nextCursor) {
                                                                                      fetchedResults = [NSMutableArray arrayWithArray:results];
                                                                                      currentCursor = nextCursor;
                                                                                  }
                                                                                  failure:^(NSError *error) {
                                                                                      responseError = error;
                                                                                  }];
        
        [[task should] beNonNil];
        [[theValue(task.state) should] equal:theValue(NSURLSessionTaskStateRunning)];
        
        [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
        
        [[fetchedResults shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
        [[expectFutureValue(@(fetchedResults.count)) shouldEventuallyBeforeTimingOutAfter(10.0)] beGreaterThan:@0];
        
        [[expectFutureValue(@(currentCursor)) shouldEventuallyBeforeTimingOutAfter(10.0)] beGreaterThan:theValue(0)];
    });
    
    it (@"can GET a resource from the API", ^{
        __block id fetchedObject = nil;
        __block NSError *responseError = nil;
        
        NSDictionary *showParameters = @{
            @"username": @"justin"
        };
        
        NSURLSessionDataTask *task = [[PAPIManager sharedManager] getResource:@"users/show"
                                                               withParameters:showParameters
                                                                      success:^(id object) {
                                                                          fetchedObject = object;
                                                                      }
                                                                      failure:^(NSError *error) {
                                                                          responseError = error;
                                                                      }];
        
        [[task should] beNonNil];
        [[theValue(task.state) should] equal:theValue(NSURLSessionTaskStateRunning)];
        
        [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];

        [[fetchedObject shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
    });
    
    it (@"can GET a resource from the API and serialize the data into the correct PResult class", ^{
        __block PUserResult *fetchedUserResult = nil;
        __block NSError *responseError = nil;
        
        NSDictionary *showParameters = @{
            @"username": @"justin"
        };
        
        NSURLSessionDataTask *task = [[PAPIManager sharedManager] getResource:@"users/show"
                                                               withParameters:showParameters
                                                                      success:^(PUserResult *userResult) {
                                                                          fetchedUserResult = userResult;
                                                                      }failure:^(NSError *error) {
                                                                          responseError = error;
                                                                      }];
        
        [[task should] beNonNil];
        [[theValue(task.state) should] equal:theValue(NSURLSessionTaskStateRunning)];
        
        [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
        
        [[fetchedUserResult shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
        [[fetchedUserResult shouldEventuallyBeforeTimingOutAfter(10.0)] beMemberOfClass:[PUserResult class]];
    });
});

SPEC_END
