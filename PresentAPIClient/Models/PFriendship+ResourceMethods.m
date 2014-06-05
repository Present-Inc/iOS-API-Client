//
//  PFriendship+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PFriendship+ResourceMethods.h"

#import "PUser.h"

@implementation PFriendship (ResourceMethods)

+ (NSString*)forwardFriendshipResource {
    return [self resourceWithString:@"list_user_forward_friendships"];
}

+ (NSString*)backwardFriendshipResource {
    return [self resourceWithString:@"list_user_backward_friendships"];
}

+ (NSURLSessionDataTask*)createFriendshipWithUser:(PUser *)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *friendshipParameters = @{
        @"user_id": user._id
    };
    
    return [PFriendship post:[PFriendship createResource]
              withParameters:friendshipParameters
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask*)deleteFriendshipWithUser:(PUser *)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *friendshipParameters = @{
        @"user_id": user._id
    };
    
    return [PFriendship post:[PFriendship destroyResource]
              withParameters:friendshipParameters
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask*)getForwardFriendshipsForUser:(PUser *)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *friendshipParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": user._id
    }];
    
    if (user.friendsCursor > 0) {
        [friendshipParameters setObject:@(user.friendsCursor) forKey:@"cursor"];
    }
    
    return [PFriendship getCollectionAtResource:[PFriendship forwardFriendshipResource]
                                 withParameters:friendshipParameters
                                        success:success
                                        failure:failure];
}

+ (NSURLSessionDataTask*)getBackwardFriendshipsForUser:(PUser *)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *friendshipParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": user._id
    }];
    
    if (user.followersCursor > 0) {
        [friendshipParameters setObject:@(user.followersCursor) forKey:@"cursor"];
    }
    
    return [PFriendship getCollectionAtResource:[PFriendship backwardFriendshipResource]
                                 withParameters:friendshipParameters
                                        success:success
                                        failure:failure];
}

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PFriendship createFriendshipWithUser:self.targetUser
                                         success:success
                                         failure:failure];
}

- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PFriendship deleteFriendshipWithUser:self.targetUser
                                         success:success
                                         failure:failure];
}

@end

