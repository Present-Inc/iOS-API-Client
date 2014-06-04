//
//  PActivity+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PActivity+ResourceMethods.h"

@implementation PActivity (ResourceMethods)

+ (NSString*)listMyActivityResource {
    return [PActivity resourceWithString:@"list_my_activities"];
}

+ (NSURLSessionDataTask*)getActivityForCurrentUserWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *activityParameters = [NSMutableDictionary dictionary];
    if (cursor > 0) {
        [activityParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PActivity getCollectionAtResource:[PActivity listMyActivityResource]
                               withParameters:activityParameters
                                      success:success
                                      failure:failure];
}

@end

