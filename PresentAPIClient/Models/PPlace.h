//
//  PPlace.h
//  Present
//
//  Created by Justin Makaila on 5/1/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

#import "PLocation.h"

@interface PPlace : PObject <PObjectSubclassing>

@property (strong, nonatomic) NSString *fourSquareVenueId;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) PLocation *location;

//@property (strong, nonatomic) PProfile *profile;
@property (nonatomic) NSInteger videosCount;
@property (strong, nonatomic) NSMutableArray *videos;

@end

@interface PPlace (ResourceMethods)

+ (NSURLSessionDataTask*)getPlacesMatchingQueryString:(NSString*)queryString nearCoordinate:(CLLocationCoordinate2D)coordinate cursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getPlaceWithId:(NSString*)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)getVideosWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
