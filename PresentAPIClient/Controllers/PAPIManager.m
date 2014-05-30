//
//  PVideoAPIManager.m
//  Present
//
//  Created by Justin Makaila on 2/26/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Reachability.h>

#import "PAPIManager.h"
#import "PUserContext.h"
#import "PResult.h"
#import "PResponse.h"
#import "PUser+SubjectiveObjectMeta.h"

static NSString *const PVideoAPIURLString = @"https://api.present.tv/v1/";

#define PUserContextUserId       @"Present-User-Context-User-Id"
#define PUserContextSessionToken @"Present-User-Context-Session-Token"

@implementation PAPIManager

+ (void)start {
    [PAPIManager sharedManager];
}

+ (instancetype)sharedManager {
    static PAPIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PAPIManager alloc] initWithBaseURL:[NSURL URLWithString:PVideoAPIURLString]];
        
        _sharedManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedManager.responseSerializer = [PJSONResponseSerializer serializer];
        
        [[Reachability reachabilityForInternetConnection] startNotifier];
    });
    
    return _sharedManager;
}

/**
 *  Sets the HTTP headers for interacting with the Present API
 *  based on the supplied PUserContext
 *
 *  @param userContext The user context to use for the HTTP headers
 */
- (void)setUserContext:(PUserContext *)userContext {
    [self.requestSerializer setValue:userContext.userResult.user._id forHTTPHeaderField:PUserContextUserId];
    [self.requestSerializer setValue:userContext.sessionToken forHTTPHeaderField:PUserContextSessionToken];
}

/**
 *  Clears the HTTP headers for the current PUserContext, closes
 *  Facebook session.
 *
 *  @discussion May soon include clearing Twitter credentials
 */
- (void)clearUserContext {
    [self.requestSerializer setValue:nil forHTTPHeaderField:PUserContextUserId];
    [self.requestSerializer setValue:nil forHTTPHeaderField:PUserContextSessionToken];
}

- (BOOL)isReachableViaWWAN {
    return [Reachability reachabilityForInternetConnection].isReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return [Reachability reachabilityForInternetConnection].isReachableViaWiFi;
}

- (BOOL)isReachable {
    return [Reachability reachabilityForInternetConnection].isReachable;
}

#pragma mark - API Interaction

#pragma mark Task Management

- (void)cancelTasksWithDescription:(NSString *)description {
    for (NSURLSessionTask *task in self.tasks) {
        if ([task.taskDescription isEqualToString:description]) {
            [task cancel];
        }
    }
}

- (void)cancelTasksWithIdentifier:(NSUInteger)identifier {
    for (NSURLSessionTask *task in self.tasks) {
        if (task.taskIdentifier == identifier) {
            [task cancel];
        }
    }
}

#pragma mark API Methods

- (NSURLSessionDataTask*)getResource:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [self GET:resource
          parameters:parameters
             success:[self successBlockWithCompletion:success]
             failure:[self failureBlockWithCompletion:failure]];
}

- (NSURLSessionDataTask*)getCollectionAtResource:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    return [self GET:resource
          parameters:parameters
             success:[self collectionSuccessBlockWithCompletion:success]
             failure:[self failureBlockWithCompletion:failure]];
}

- (NSURLSessionDataTask*)post:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [self POST:resource
           parameters:parameters
              success:[self successBlockWithCompletion:success]
              failure:[self failureBlockWithCompletion:failure]];
}

- (NSURLSessionDataTask*)postCollection:(NSString*)resource withParameters:(NSDictionary*)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    return [self POST:resource
           parameters:parameters
              success:[self collectionSuccessBlockWithCompletion:success]
              failure:[self failureBlockWithCompletion:failure]];
}

- (NSURLSessionUploadTask*)uploadTaskWithStreamedRequest:(NSURLRequest*)request progress:(NSProgress**)progress success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [super uploadTaskWithStreamedRequest:request
                                       progress:progress
                              completionHandler:[self multipartBlockWithSuccess:success failure:failure]];
}

#pragma mark Response Blocks

- (void(^)(NSURLSessionDataTask *, NSDictionary *))successBlockWithCompletion:(PObjectResultBlock)completion {
    return ^(NSURLSessionDataTask * __unused task, NSDictionary *responseDictionary) {
        PResourceResponse *responseObject = [MTLJSONAdapter modelOfClass:PResponse.class fromJSONDictionary:responseDictionary error:nil];
        
        if (completion) {
            completion(responseObject.result);
        }
    };
}

/**
 *  Block for all successful collection requests. Deserializes
 *  JSON into a usable PResponse object
 *
 *  @param completion The handler to call upon completion
 */
- (void(^)(NSURLSessionDataTask *, NSDictionary *))collectionSuccessBlockWithCompletion:(PCollectionResultsBlock)completion {
    return ^(NSURLSessionDataTask * __unused task, NSDictionary *responseDictionary) {
        PCollectionResponse *responseObject = [MTLJSONAdapter modelOfClass:PResponse.class fromJSONDictionary:responseDictionary error:nil];
        
        if (completion) {
            completion(responseObject.results, responseObject.nextCursor);
        }
    };
}

/**
 *  Block for all failed requests
 *
 *  @param completion The handler to call upon completion
 */
- (void(^)(NSURLSessionDataTask *, NSError *))failureBlockWithCompletion:(PFailureBlock)completion {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(error);
        }
    };
}

- (void(^)(NSURLResponse *, id, NSError *))multipartBlockWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    // !!!: These look weird, but they work and are shorter than storing the blocks in variables
    return ^(NSURLResponse *response, NSDictionary *data, NSError *error) {
        if (!error) {
            [self successBlockWithCompletion:success](nil, data);
        }else {
            [self failureBlockWithCompletion:failure](nil, error);
        }
    };
}

@end
