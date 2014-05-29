//
//  PLike.m
//  Present
//
//  Created by Justin Makaila on 3/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser.h"
#import "PLike.h"
#import "PVideo.h"
#import "PResult.h"

@implementation PLike

+ (NSString*)classResource {
    return @"likes";
}

+ (Class)resourceResultClass {
    return PLikeResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"userResult": @"sourceUser",
        @"videoResult": @"targetVideo"
    }];
}

+ (NSValueTransformer*)userResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PUserResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)videoResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PVideoResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

+ (instancetype)likeForVideo:(PVideo *)video {
    PLike *like = [PLike object];
    
    like.userResult = [[PUserResult alloc] init];
    like.userResult.user = [PUser currentUser];
    
    like.videoResult = [[PVideoResult alloc] init];
    like.videoResult.video = video;
    like.videoResult.subjectiveObjectMeta.like = [PRelation relationForward:YES backward:NO];
    like.videoResult.subjectiveObjectMeta.view = [PUser currentUser].views.get(video);
    
    return like;
}

- (PUser*)user {
    return self.userResult.user;
}

- (PVideo*)video {
    return self.videoResult.video;
}

@end

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
    return [PLike createLikeForVideo:self.video
                             success:success
                             failure:failure];
}

- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PLike deleteLikeForVideo:self.video
                             success:success
                             failure:failure];
}

@end
