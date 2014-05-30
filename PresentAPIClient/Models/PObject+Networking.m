//
//  PObject+Networking.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//


#import "PObject+Networking.h"
#import "PResult.h"
#import "PUser+SubjectiveObjectMeta.h"

static NSString *CreateRoute  = @"create";
static NSString *ShowRoute    = @"show";
static NSString *ListRoute    = @"list";
static NSString *UpdateRoute  = @"update";
static NSString *DestroyRoute = @"destroy";

@implementation PObject (Networking)

+ (NSString*)resourceWithString:(NSString*)pathComponent {
    return [[[self class] classResource] stringByAppendingPathComponent:pathComponent];
}

+ (NSString*)createResource {
    return [self resourceWithString:CreateRoute];
}

+ (NSString*)listResource {
    return [self resourceWithString:ListRoute];
}

+ (NSString*)showResource {
    return [self resourceWithString:ShowRoute];
}

+ (NSString*)updateResource {
    return [self resourceWithString:UpdateRoute];
}

+ (NSString*)destroyResource {
    return [self resourceWithString:DestroyRoute];
}

+ (PObjectResultBlock)objectSuccessBlockWithCompletionHandler:(PObjectResultBlock)completion {
    return ^(NSDictionary *object) {
        PResult *result = [MTLJSONAdapter modelOfClass:[[self class] resourceResultClass] fromJSONDictionary:object error:nil];
        
        if (completion) {
            completion(result);
        }
    };
}

+ (PCollectionResultsBlock)collectionSuccessBlockWithCompletionHandler:(PCollectionResultsBlock)completion {
    return ^(NSArray *results, NSInteger nextCursor) {
        NSMutableArray *collection = [NSMutableArray array];
        for (NSDictionary *objectJSON in results) {
            PResult *model = [MTLJSONAdapter modelOfClass:[[self class] resourceResultClass] fromJSONDictionary:objectJSON error:nil];
            [collection addObject:model];
        }
        
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:collection.count];
        for (PResult *result in collection) {
            [objects addObject:result.object];
            [[PUser currentUser] addSubjectiveRelationshipsForResult:result];
        }
        
        if (completion) {
            completion(objects, nextCursor);
        }
    };
}

+ (NSURLSessionDataTask*)getResource:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [[PAPIManager sharedManager] getResource:resource
                                     withParameters:parameters
                                            success:[[self class] objectSuccessBlockWithCompletionHandler:success]
                                            failure:failure];
}

+ (NSURLSessionDataTask*)getCollectionAtResource:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    return [[PAPIManager sharedManager] getCollectionAtResource:resource
                                                 withParameters:parameters
                                                        success:[[self class] collectionSuccessBlockWithCompletionHandler:success]
                                                        failure:failure];
}

+ (NSURLSessionDataTask*)post:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [[PAPIManager sharedManager] post:resource
                              withParameters:parameters
                                     success:[[self class] objectSuccessBlockWithCompletionHandler:success]
                                     failure:failure];
}

+ (NSURLSessionDataTask*)postCollection:(NSString *)resource withParameters:(NSDictionary *)parameters success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    return [[PAPIManager sharedManager] postCollection:resource
                                        withParameters:parameters
                                               success:[[self class] collectionSuccessBlockWithCompletionHandler:success]
                                               failure:failure];
}

+ (NSURLSessionDataTask*)post:(NSString *)resource multipartFormDataWithBlock:(void (^) (id<AFMultipartFormData>))block parameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [[self class] post:resource
   multipartFormDataWithBlock:block
                     progress:nil
                   parameters:parameters
                      success:success
                      failure:failure];
}

+ (NSURLSessionDataTask*)post:(NSString *)resource multipartFormDataWithBlock:(void (^) (id<AFMultipartFormData>))block progress:(NSProgress**)progress parameters:(NSDictionary *)parameters success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSString *urlString = [[NSURL URLWithString:resource relativeToURL:[PAPIManager sharedManager].baseURL] absoluteString];
    
    NSMutableURLRequest *request = [[PAPIManager sharedManager].requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                       URLString:urlString
                                                                                                      parameters:parameters
                                                                                       constructingBodyWithBlock:block];
    
    NSURLSessionUploadTask *task = [[PAPIManager sharedManager] uploadTaskWithStreamedRequest:request
                                                                                     progress:progress
                                                                                      success:[[self class] objectSuccessBlockWithCompletionHandler:success]
                                                                                      failure:failure];
    [task resume];
    return task;
}

@end
