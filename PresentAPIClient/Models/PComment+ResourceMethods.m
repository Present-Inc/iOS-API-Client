//
//  PComment+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PComment+ResourceMethods.h"

#import "PVideo.h"

@implementation PComment (ResourceMethods)

+ (NSString*)listVideoCommentsResource {
    return [self resourceWithString:@"list_video_comments"];
}

+ (NSURLSessionDataTask*)getCommentWithId:(NSString *)id success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *commentParameters = @{
        @"comment_id": id
    };
    
    return [PComment getResource:[PComment showResource]
                  withParameters:commentParameters
                         success:success
                         failure:failure];
}

+ (NSURLSessionDataTask*)getCommentsForVideo:(PVideo *)video success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *commentParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:video._id, @"video_id", nil];
    if (video.commentsCursor > 0) {
        [commentParameters setObject:@(video.commentsCursor) forKey:@"cursor"];
    }
    
    return [PComment getCollectionAtResource:[PComment listVideoCommentsResource]
                              withParameters:commentParameters
                                     success:success
                                     failure:failure];
}

+ (NSURLSessionDataTask*)deleteComment:(PComment *)comment success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *commentParameters = @{
        @"comment_id": comment._id
    };
    
    return [PComment post:[PComment destroyResource]
           withParameters:commentParameters
                  success:success
                  failure:failure];
}

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *createParameters = @{
        @"video_id": self.targetVideo._id,
        @"body": self.body
    };
    
    return [PComment post:[PComment createResource]
           withParameters:createParameters
                  success:success
                  failure:failure];
}

- (NSURLSessionDataTask*)updateWithBody:(NSString *)newBody success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *updateParameters = @{
        @"comment_id": self._id,
        @"body": newBody
    };
    
    return [PComment post:[PComment updateResource]
           withParameters:updateParameters
                  success:success
                  failure:failure];
}

@end
