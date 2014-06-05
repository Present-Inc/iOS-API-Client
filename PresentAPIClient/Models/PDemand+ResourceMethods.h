//
//  PDemand+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Networking.h"
#import "PDemand.h"

@interface PDemand (ResourceMethods)

+ (NSURLSessionDataTask*)deleteDemandForUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getForwardDemandsForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getBackwardDemandsForUser:(PUser*)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
