//
//  PObject+NetworkingSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PObject+Networking.h"

#import "PVideo.h"
#import "PUser.h"


SPEC_BEGIN(PObject_NetworkingSpec)

describe(@"PObject+Networking", ^{
    it (@"can provide a resource route for any string", ^{
        /**
         *  PObject+Networking is intended to be used by subclasses of PObject
         *  that conform to PObjectNetworking.
         */
        NSString *resourceString = [PVideo resourceWithString:@"methodResource"];
        [[resourceString should] equal:@"videos/methodResource"];
    });
    
    it (@"can provide a resource for create, list, show, update, and destroy", ^{
        [[[PVideo createResource] should] equal:@"videos/create"];
        [[[PVideo listResource] should] equal:@"videos/list"];
        [[[PVideo showResource] should] equal:@"videos/show"];
        [[[PVideo updateResource] should] equal:@"videos/update"];
        [[[PVideo destroyResource] should] equal:@"videos/destroy"];
    });
    
    context (@"getting/posting data", ^{
        it (@"can get a model from a resource, returning on the retrieved model as the result", ^{
            __block NSError *responseError = nil;
            __block id userResponse = nil;
            
            [PUser getUserWithUsername:@"justin" success:^(id user) {
                userResponse = user;
            }failure:^(NSError *error) {
                responseError = error;
            }];
            
            [[userResponse shouldEventuallyBeforeTimingOutAfter(10.0)] beMemberOfClass:[PUser class]];
            [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
        });
        
        it (@"can get a collection from a resource, returning only the retrieved models in results", ^{
            __block NSInteger cursor = 0;
            __block NSMutableArray *responseResults = [NSMutableArray array];
            __block NSError *responseError = nil;
            
            PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
                if (cursor == 0) {
                    [responseResults removeAllObjects];
                }
                
                for (id object in results) {
                    [[object should] beMemberOfClass:[PVideo class]];
                }
                
                [responseResults addObjectsFromArray:results];
                cursor = nextCursor;
            };
            
            PFailureBlock failureBlock = ^(NSError *error) {
                responseError = error;
            };
            
            [PVideo getBrandNewVideosWithCursor:cursor
                                        success:successBlock
                                        failure:failureBlock];
            
            [[responseError shouldEventuallyBeforeTimingOutAfter(10.0)] beNil];
            
            [[expectFutureValue(@(responseResults.count)) shouldEventuallyBeforeTimingOutAfter(10.0)] equal:@30];
            [[expectFutureValue(@(cursor)) shouldEventuallyBeforeTimingOutAfter(10.0)] equal:@30];
        });
    });
});

SPEC_END
