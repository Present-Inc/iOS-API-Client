//
//  PUser+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser+ResourceMethods.h"
#import "PUser+SubjectiveObjectMeta.h"
#import "PUser+CurrentUser.h"

#import "PUserContext.h"
#import "PDemand+ResourceMethods.h"
#import "PLike+ResourceMethods.h"
#import "PFriendship+ResourceMethods.h"
#import "PVideo+ResourceMethods.h"
#import "PResult.h"

@implementation PUser (ResourceMethods)

+ (NSString*)currentUserResource {
    return [PUser resourceWithString:@"show_me"];
}

+ (NSString*)brandNewUsersResource {
    return [PUser resourceWithString:@"list_brand_new_users"];
}

+ (NSString*)featuredUsersResource {
    return [PUser resourceWithString:@"list_featured_users"];
}

+ (NSString*)popularUsersResource {
    return [PUser resourceWithString:@"list_popular_users"];
}

+ (NSString*)searchResource {
    return [PUser resourceWithString:@"search"];
}

+ (NSString*)resetPasswordResource {
    return [PUser resourceWithString:@"reset_password"];
}

+ (NSString*)batchSearchResource {
    return [PUser resourceWithString:@"batch_search"];
}

+ (NSString*)updateProfilePictureResource {
    return [PUser resourceWithString:@"update_profile_picture"];
}

+ (NSString*)requestPasswordResetResource {
    return [PUser resourceWithString:@"request_password_reset"];
}

+ (NSURLSessionDataTask*)loginWithUsername:(NSString *)username password:(NSString *)password success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *loginParameters = @{
        @"username": username.lowercaseString,
        @"password": password
    };
    
    PObjectResultBlock successBlock = ^(PUserContext *context) {
        PUser *loggedInUser = context.userResult.user;
        [PUser _setCurrentUser:loggedInUser];
        
        if (success) {
            success(loggedInUser);
        }
    };
    
    return [PUserContext authenticateWithCredentials:loginParameters
                                             success:successBlock
                                             failure:failure];
}

+ (NSURLSessionDataTask*)signUpWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email profilePicture:(UIImage *)image success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    __block NSMutableDictionary *userParameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                  @"username": username,
                                                                                                  @"password": password,
                                                                                                  @"email": email
                                                                                                  }];
    
    PObjectResultBlock successBlock = ^(id __unused object) {
        [self loginWithUsername:userParameters[@"username"]
                       password:userParameters[@"password"]
                        success:^(PUser *user) {
                            if (image) {
                                [user updateProfilePicture:image
                                                   success:success
                                                   failure:failure];
                            }else {
                                if (success) {
                                    success(user);
                                }
                            }
                        }
                        failure:failure];
    };
    
    return [PUser post:[self createResource]
        withParameters:userParameters
               success:successBlock
               failure:failure];
}

+ (NSURLSessionDataTask*)requestPasswordResetForEmail:(NSString *)email success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *resetPasswordParameters = @{
        @"username": email
    };
    
    return [PUser post:[self requestPasswordResetResource]
        withParameters:resetPasswordParameters
               success:success
               failure:failure];
}

+ (void)logOut {
    [PUserContext logOut];
    [PUser _setCurrentUser:nil];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

+ (NSURLSessionDataTask*)getUserWithUsername:(NSString *)username success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *showParameters = @{
        @"username": username
    };
    
    return [PUser getResource:[PUser showResource]
               withParameters:showParameters
                      success:success
                      failure:failure];
}

+ (NSURLSessionDataTask*)getUserWithId:(NSString *)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *userParameters = @{
        @"user_id": objectId
    };
    
    return [PUser getResource:[PUser showResource]
               withParameters:userParameters
                      success:success
                      failure:failure];
}

+ (NSURLSessionDataTask*)getCurrentUserWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    PUserContext *currentContext = [PUserContext currentContext];
    if (currentContext) {
        NSDictionary *parameters = @{
                                     @"user_id": [PUser currentUser]._id
                                     };
        
        PObjectResultBlock successBlock = ^(PUserResult *result) {
            PUser *currentUser = [PUser currentUser];
            [currentUser mergeValuesForKeysFromModel:result.user];
            
            [PUserContext currentContext].userResult.user = currentUser;
            [[PUserContext currentContext] saveToDisk];
            
            if (success) {
                success(currentUser);
            }
        };
        
        return [PUser getResource:[PUser currentUserResource]
                   withParameters:parameters
                          success:successBlock
                          failure:failure];
    }else {
        return nil;
    }
}

+ (NSURLSessionDataTask*)getBrandNewUsersWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *userParameters = [NSMutableDictionary dictionary];
    
    if (cursor > 0) {
        [userParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PUser getCollectionAtResource:[self brandNewUsersResource]
                           withParameters:userParameters
                                  success:success
                                  failure:failure];
}

+ (NSURLSessionDataTask*)getFeaturedUsersWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *userParameters = [NSMutableDictionary dictionary];
    
    if (cursor > 0) {
        [userParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PUser getCollectionAtResource:[self featuredUsersResource]
                           withParameters:userParameters
                                  success:success
                                  failure:failure];
}

+ (NSURLSessionDataTask*)getPopularUsersWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSDictionary *userParameters;
    
    if (cursor > 0) {
        userParameters = @{
                           @"cursor": @(cursor)
                           };
    }
    
    return [PUser getCollectionAtResource:[self popularUsersResource]
                           withParameters:userParameters
                                  success:success
                                  failure:failure];
}

+ (NSURLSessionDataTask*)getContactsOnPresentMatchingPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails cursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *contactsParameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                              @"emails": emails,
                                                                                              @"phone_numbers": phoneNumbers
                                                                                              }];
    
    if (cursor > 0) {
        [contactsParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PUser postCollection:[PUser batchSearchResource]
                  withParameters:contactsParameters
                         success:success
                         failure:failure];
}

+ (NSURLSessionDataTask*)getTwitterFriendsOnPresent:(NSArray*)twitterFriends withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *twitterParameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                             @"twitter_ids": twitterFriends
                                                                                             }];
    
    if (cursor > 0) {
        [twitterParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PUser postCollection:[PUser batchSearchResource]
                  withParameters:twitterParameters
                         success:success
                         failure:failure];
}

+ (NSURLSessionDataTask*)getFacebookFriendsOnPresent:(NSArray*)facebookFriends withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *facebookParameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                              @"facebook_ids": facebookFriends,
                                                                                              }];
    
    if (cursor > 0) {
        [facebookParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PUser postCollection:[PUser batchSearchResource]
                  withParameters:facebookParameters
                         success:success
                         failure:failure];
}

+ (NSURLSessionDataTask*)getUsersMatchingQueryString:(NSString*)queryString withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSDictionary *searchParameters = @{
        @"query": queryString
    };
    
    return [PUser getCollectionAtResource:[self searchResource]
                           withParameters:searchParameters
                                  success:success
                                  failure:failure];
}

- (NSURLSessionDataTask*)getDemandedUsersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.demandedUsersCursor == 0) {
            [self.demandedUsers removeAllObjects];
        }
        
        NSMutableArray *demandedUsers = [NSMutableArray arrayWithCapacity:results.count];
        for (PDemandResult *result in results) {
            PUser *user = result.demand.targetUser;
            [demandedUsers addObject:user];
        }
        
        [self.demandedUsers addObjectsFromArray:demandedUsers];
        
        if (success) {
            success(results, nextCursor);
        }
        
        self.demandedUsersCursor = nextCursor;
    };
    
    return [PDemand getForwardDemandsForUser:self
                                     success:successBlock
                                     failure:failure];
}

- (NSURLSessionDataTask*)getDemandingUsersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.demandingUsersCursor == 0) {
            [self.demandingUsers removeAllObjects];
        }
        
        NSMutableArray *demandingUsers = [NSMutableArray arrayWithCapacity:results.count];
        for (PDemandResult *result in results) {
            PUser *user = result.demand.sourceUser;
            [demandingUsers addObject:user];
        }
        
        [self.demandingUsers addObjectsFromArray:demandingUsers];
        
        if (success) {
            success(results, nextCursor);
        }
        
        self.demandingUsersCursor = nextCursor;
    };
    
    return [PDemand getBackwardDemandsForUser:self
                                      success:successBlock
                                      failure:failure];
}

- (NSURLSessionDataTask*)getLikedVideosWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.likedVideosCursor == 0) {
            [self.likedVideos removeAllObjects];
        }
        
        // !!!: This needs to be revised...
        NSMutableArray *likedVideos = [NSMutableArray arrayWithCapacity:results.count];
        for (PLikeResult *result in results) {
            result.like.sourceUserResult = [[PUserResult alloc] init];
            result.like.sourceUserResult.user = self;
            
            PVideo *video = result.like.targetVideo;
            [likedVideos addObject:video];
            
            [[PUser currentUser] addSubjectiveRelationships:result.like.targetVideoResult.subjectiveObjectMeta forObject:video];
        }
        
        [self.likedVideos addObjectsFromArray:likedVideos];
        
        if (success) {
            success(likedVideos, nextCursor);
        }
        
        self.likedVideosCursor = nextCursor;
    };
    
    return [PLike getLikedVideosForUser:self
                                success:successBlock
                                failure:failure];
}

- (NSURLSessionDataTask*)getVideosWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.videosCursor == 0) {
            [self.videos removeAllObjects];
        }
        
        NSMutableArray *videos = [NSMutableArray arrayWithCapacity:results.count];
        for (PVideoResult *result in results) {
            PVideo *video = result.video;
            video.creatorUserResult = [[PUserResult alloc] init];
            video.creatorUserResult.user = self;
            
            [videos addObject:video];
        }
        
        [self.videos addObjectsFromArray:videos];
        
        if (success) {
            success(videos, nextCursor);
        }
        
        self.videosCursor = nextCursor;
    };
    
    return [PVideo getVideosForUser:self
                            success:successBlock
                            failure:failure];
}

- (NSURLSessionDataTask*)getFollowersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.followersCursor == 0) {
            [self.followers removeAllObjects];
        }
        
        NSMutableArray *followers = [NSMutableArray arrayWithCapacity:results.count];
        for (PFriendshipResult *result in results) {
            PUser *follower = result.friendship.sourceUser;
            [followers addObject:follower];
        }
        
        [self.followers addObjectsFromArray:followers];
        
        if (success) {
            success(followers, nextCursor);
        }
        
        self.followersCursor = nextCursor;
    };
    
    return [PFriendship getBackwardFriendshipsForUser:self
                                              success:successBlock
                                              failure:failure];
}

- (NSURLSessionDataTask*)getFriendsWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (self.friendsCursor == 0) {
            [self.friends removeAllObjects];
        }
        
        NSMutableArray *friends = [NSMutableArray arrayWithCapacity:results.count];
        for (PFriendshipResult *result in results) {
            PUser *friend = result.friendship.targetUser;
            [friends addObject:friend];
        }
        
        [self.friends addObjectsFromArray:friends];
        
        if (success) {
            success(friends, nextCursor);
        }
        
        self.friendsCursor = nextCursor;
    };
    
    return [PFriendship getForwardFriendshipsForUser:self
                                             success:successBlock
                                             failure:failure];
}

- (NSURLSessionDataTask*)updateProperties:(NSDictionary *)properties success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PUser post:[PUser updateResource]
        withParameters:properties
               success:success
               failure:failure];
}

- (NSURLSessionDataTask*)updateProfilePicture:(UIImage *)profilePicture success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    void (^constructingBlock) (id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImagePNGRepresentation(profilePicture);
        
        [formData appendPartWithFileData:imageData
                                    name:@"profile_picture"
                                fileName:[NSString stringWithFormat:@"profile_picture_%@.png", self._id]
                                mimeType:@"image/png"];
    };
    
    return [PUser post:[PUser updateProfilePictureResource]
multipartFormDataWithBlock:constructingBlock
            parameters:nil
               success:^(PUserResult *userResult) {
                   PUser *currentUser = [PUser currentUser];
                   [currentUser mergeValuesForKeysFromModel:userResult.user];
                   
                   if (success) {
                       success(userResult);
                   }
               }
               failure:failure];
}

@end

