//
//  PComment+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Networking.h"
#import "PComment.h"

@interface PComment (ResourceMethods)

+ (NSURLSessionDataTask*)getCommentWithId:(NSString*)id success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getCommentsForVideo:(PVideo*)video success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)deleteComment:(PComment*)comment success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)updateWithBody:(NSString*)newBody success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
