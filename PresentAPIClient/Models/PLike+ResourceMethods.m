//
//  PLike+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PLike+ResourceMethods.h"

#import "PVideo.h"
#import "PUser.h"

@implementation PLike (ResourceMethods)

+ (NSString*)listUserForwardLikesResource {
    return [PLike resourceWithString:@"list_user_forward_likes"];
}

+ (NSString*)listVideoBackwardLikesResource {
    return [PLike resourceWithString:@"list_video_backward_likes"];
}

+ (NSURLSessionDataTask*)getLikedVideosForUser:(PUser *)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *likeParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": user._id,
    }];
    
    if (user.likedVideosCursor > 0) {
        [likeParameters setObject:@(user.likedVideosCursor) forKey:@"cursor"];
    }
    
    return [PLike getCollectionAtResource:[PLike listUserForwardLikesResource]
                           withParameters:likeParameters
                                  success:success
                                  failure:failure];
}

+ (NSURLSessionDataTask*)getLikesForVideo:(PVideo *)video success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *likeParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"video_id": video._id
    }];
    
    if (video.likesCursor > 0) {
        [likeParameters setObject:@(video.likesCursor) forKey:@"cursor"];
    }
    
    return [PLike getCollectionAtResource:[PLike listVideoBackwardLikesResource]
                           withParameters:likeParameters
                                  success:success
                                  failure:failure];
}

+ (NSURLSessionDataTask*)createLikeForVideo:(PVideo *)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *likeParameters = @{
        @"video_id": video._id
    };
    
    return [PLike post:[PLike createResource]
        withParameters:likeParameters
               success:success
               failure:failure];
}

+ (NSURLSessionDataTask*)deleteLikeForVideo:(PVideo *)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *likeParameters = @{
        @"video_id": video._id
    };
    
    return [PLike post:[PLike destroyResource]
        withParameters:likeParameters
               success:success
               failure:failure];
}

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PLike createLikeForVideo:self.targetVideo
                             success:success
                             failure:failure];
}

- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PLike deleteLikeForVideo:self.targetVideo
                             success:success
                             failure:failure];
}

@end
