//
//  PPlace+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Networking.h"
#import "PPlace.h"

#import <CoreLocation/CoreLocation.h>

@interface PPlace (ResourceMethods)

+ (NSURLSessionDataTask*)getPlacesMatchingQueryString:(NSString*)queryString nearCoordinate:(CLLocationCoordinate2D)coordinate cursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getPlaceWithId:(NSString*)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)getVideosWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
