//
//  PActivity+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PActivity.h"
#import "PObject+Networking.h"

@interface PActivity (ResourceMethods)

/**
 *  GETs the most recent activity for a user
 *
 *  @param cursor  The cursor for the request
 *  @param success PCollectionResultsBlock to call on success
 *  @param failure PFailureBlock to call on failure
 *
 *  @return a running NSURLSessionDataTask
 */
+ (NSURLSessionDataTask*)getActivityForCurrentUserWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

@end
