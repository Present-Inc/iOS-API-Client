//
//  PPlace.m
//  Present
//
//  Created by Justin Makaila on 5/1/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PPlace.h"
#import "PResult.h"

@implementation PPlace

+ (NSString*)classResource {
    return @"places";
}

+ (Class)resourceResultClass {
    return PPlaceResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"fourSquareVenueId": @"fourSquareVenueId",
        @"name": @"name",
        @"location": @"location",
        @"videosCount": @"videos.count",
        @"videos": @"videos.results"
    }];
}

+ (NSValueTransformer*)locationJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PLocation.class];
}

@end

@implementation PPlace (ResourceMethods)

+ (NSString*)searchResource {
    return [PPlace resourceWithString:@"search"];
}

+ (NSURLSessionDataTask*)getPlacesMatchingQueryString:(NSString *)queryString nearCoordinate:(CLLocationCoordinate2D)coordinate cursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionary];
    
    if (queryString) {
        [searchParameters setObject:queryString forKey:@"query"];
    }
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        [searchParameters setObject:[NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude] forKey:@"lat_lng"];
    }
    
    if (cursor > 0) {
        [searchParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PPlace getCollectionAtResource:[PPlace searchResource]
                            withParameters:searchParameters
                                   success:success
                                   failure:failure];
}

+ (NSURLSessionDataTask*)getPlaceWithId:(NSString *)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *showParameters = @{
        @"place_id": objectId
    };
    
    return [PPlace getResource:[PPlace showResource]
                withParameters:showParameters
                       success:success
                       failure:failure];
}

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSLog(@"%s is not yet implemented", __PRETTY_FUNCTION__);
    return nil;
}

@end
