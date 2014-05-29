//
//  PObject+Networking.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject.h"
#import "PObjectNetworking.h"

#import "PAPIManager.h"

@interface PObject (Networking)

/**
 *  Convenience method for returning a string representing
 *  a resource method
 *
 *  @param pathComponent The path component to be appended
 *
 *  @return A string representing the resource method
 *
 *  @see Returns @":class/pathComponent"
 */
+ (NSString*)resourceWithString:(NSString*)pathComponent;

/**
 *  Returns the create resource
 *
 *  @return The create resource method
 */
+ (NSString*)createResource;

/**
 *  Returns the list resource
 *
 *  @return The list resource method
 */
+ (NSString*)listResource;

/**
 *  Returns the show resource
 *
 *  @return The show resource method
 */
+ (NSString*)showResource;

/**
 *  Returns the update resource
 *
 *  @return The update resource method
 */
+ (NSString*)updateResource;

/**
 *  Returns the destroy resource
 *
 *  @return The destroy resource method
 */
+ (NSString*)destroyResource;

+ (NSURLSessionDataTask*)getResource:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getCollectionAtResource:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)post:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)postCollection:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)post:(NSString*)resource multipartFormDataWithBlock:(void (^) (id<AFMultipartFormData>))block parameters:(NSDictionary*)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)post:(NSString *)resource multipartFormDataWithBlock:(void (^) (id<AFMultipartFormData>))block progress:(NSProgress**)progress parameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end

