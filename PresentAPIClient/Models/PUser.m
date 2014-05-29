//
//  PUser.m
//  Present
//
//  Created by Justin Makaila on 11/14/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PUser.h"

#import "PRelationship.h"
#import "PFriendship.h"
#import "PLike.h"
#import "PUserContext.h"
#import "PDemand.h"
#import "PLocation.h"
#import "PVideo.h"

#import "PResult.h"

#import "PExternalServices.h"

@interface PUser ()

@property (strong, nonatomic) PExternalServices *externalServices;

- (void)addFriend:(PUser*)friend;
- (void)removeFriend:(PUser*)friend;

- (void)addFollower:(PUser*)follower;
- (void)removeFollower:(PUser*)follower;

- (void)addDemand:(PUser*)demandingUser;
- (void)deleteDemand:(PUser*)demandingUser;

@end

static PUser *_currentUser;

@implementation PUser

+ (NSString*)classResource {
    return @"users";
}

+ (Class)resourceResultClass {
    return PUserResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"followerCount": @"followers.count",
        @"friendCount": @"friends.count",
        @"videoCount": @"videos.count",
        @"demandCount": @"demands.count",
        @"likeCount": @"likes.count",
        @"viewCount": @"views.count",
        @"userDescription": @"profile.description",
        @"fullName": @"profile.fullName",
        @"gender": @"profile.gender",
        @"locationName": @"profile.location",
        @"profilePictureUrlString": @"profile.picture.url",
        @"website": @"profile.website",
        @"admin": @"_isAdmin",
        @"friendships": NSNull.null,
        @"demands": NSNull.null,
        @"likes":NSNull.null,
        @"views":NSNull.null,
        @"followers": NSNull.null,
        @"followersCursor": NSNull.null,
        @"friends": NSNull.null,
        @"friendsCursor": NSNull.null,
        @"videos": NSNull.null,
        @"videosCursor": NSNull.null,
        @"likedVideos": NSNull.null,
        @"likedVideosCursor": NSNull.null,
        @"mentionedVideos": NSNull.null,
        @"mentionedVideosCursor": NSNull.null,
        @"demandingUsers": NSNull.null,
        @"demandingUsersCursor": NSNull.null,
        @"demandedUsers": NSNull.null,
        @"demandedUsersCursor": NSNull.null
    }];
}

+ (NSDictionary*)encodingBehaviorsByPropertyKey {
    NSSet *setToRemove = [NSSet setWithObjects:@"friendships", @"demands", @"likes", @"views", @"friends", @"friendsCursor", @"followers", @"followersCursor", @"videos", @"videosCursor", @"likedVideos", @"likedVideosCursor", @"mentionedVideos", @"mentionedVideosCursor", @"demandingUsers", @"demandingUsersCursor", @"demandedUsers", @"demandedUsersCursor", nil];
    return [[super encodingBehaviorsByPropertyKey] mtl_dictionaryByRemovingEntriesWithKeys:setToRemove];
}

+ (NSValueTransformer*)lastKnownLocationJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PLocation.class];
}

+ (NSValueTransformer*)externalServicesJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PExternalServices.class];
}

+ (PUser*)currentUser {
    if (!_currentUser) {
        [self setCurrentUser:[PUserContext currentContext].userResult.user];
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(PUser*)user {
    _currentUser = user;
}

#pragma mark - Instance methods

- (BOOL)isCurrentUser {
    return [self isEqual:[PUser currentUser]];
}

- (BOOL)isAuthenticated {
    return !![PUserContext currentContext];
}

- (NSURL*)profilePictureURL {
    return [NSURL URLWithString:self.profilePictureUrlString];
}

- (void)toggleFriendship {
    _currentUser.friendships.to(self) ? [_currentUser removeFriend:self] : [_currentUser addFriend:self];
}

- (void)addFriend:(PUser*)friend {
    [friend addFollower:self];
    
    [self willChangeValueForKey:@"friendCount"];
    self.friendCount++;
    [self didChangeValueForKey:@"friendCount"];
    
    [self.friends addObject:friend];
    
    [PFriendship createFriendshipWithUser:friend success:nil failure:nil];
    self.friendships.setForward(friend, YES);
    [[PUserContext currentContext] saveToDisk];
}

- (void)removeFriend:(PUser*)friend {
    [friend removeFollower:self];
    
    [self willChangeValueForKey:@"friendCount"];
    self.friendCount--;
    [self didChangeValueForKey:@"friendCount"];
    
    [self.friends removeObject:friend];
    
    [PFriendship deleteFriendshipWithUser:friend success:nil failure:nil];
    self.friendships.setForward(friend, NO);
    [[PUserContext currentContext] saveToDisk];
}

- (void)addFollower:(PUser*)follower {
    [self willChangeValueForKey:@"followerCount"];
    self.followerCount++;
    [self didChangeValueForKey:@"followerCount"];
    
    [self.followers addObject:follower];
}

- (void)removeFollower:(PUser*)follower {
    [self willChangeValueForKey:@"followerCount"];
    self.followerCount--;
    [self didChangeValueForKey:@"followerCount"];
    
    [self.followers removeObject:follower];
}

- (void)toggleDemand {
    _currentUser.demands.to(self) ? [_currentUser deleteDemand:self] : [_currentUser addDemand:self];
}

- (void)addDemand:(PUser *)demandedUser {
    [demandedUser willChangeValueForKey:@"demandCount"];
    demandedUser.demandCount++;
    [demandedUser didChangeValueForKey:@"demandCount"];
    
    [demandedUser.demandingUsers addObject:self];
    
    PDemand *demand = [PDemand demandForUser:demandedUser];
    [demand createWithSuccess:nil failure:nil];
    
    self.demands.setForward(demandedUser, YES);
    [[PUserContext currentContext] saveToDisk];
}

- (void)deleteDemand:(PUser *)demandedUser {
    [demandedUser willChangeValueForKey:@"demandCount"];
    demandedUser.demandCount--;
    [demandedUser didChangeValueForKey:@"demandCount"];
    
    [demandedUser.demandingUsers removeObject:self];
    
    [PDemand deleteDemandForUser:demandedUser success:nil failure:nil];
    
    self.demands.setForward(demandedUser, NO);
    [[PUserContext currentContext] saveToDisk];
}

#pragma mark - Accessors/Mutators

#pragma mark Collections

- (NSMutableArray*)friends {
    if (!_friends) {
        _friends = [NSMutableArray array];
    }
    
    return _friends;
}

- (NSMutableArray*)followers {
    if (!_followers) {
        _followers = [NSMutableArray array];
    }
    
    return _followers;
}

- (NSMutableArray*)videos {
    if (!_videos) {
        _videos = [NSMutableArray array];
    }
    
    return _videos;
}

- (NSMutableArray*)likedVideos {
    if (!_likedVideos) {
        _likedVideos = [NSMutableArray array];
    }
    
    return _likedVideos;
}

- (NSMutableArray*)mentionedVideos {
    if (!_mentionedVideos) {
        _mentionedVideos = [NSMutableArray array];
    }
    
    return _mentionedVideos;
}

- (NSMutableArray*)demandedUsers {
    if (!_demandedUsers) {
        _demandedUsers = [NSMutableArray array];
    }
    
    return _demandedUsers;
}

- (NSMutableArray*)demandingUsers {
    if (!_demandingUsers) {
        _demandingUsers = [NSMutableArray array];
    }
    
    return _demandingUsers;
}

#pragma mark Relationships

- (PRelationship*)friendships {
    if (!_friendships) {
        _friendships = [[PRelationship alloc] init];
    }
    
    return _friendships;
}

- (PRelationship*)likes {
    if (!_likes) {
        _likes = [[PRelationship alloc] init];
    }
    
    return _likes;
}

- (PRelationship*)demands {
    if (!_demands) {
        _demands = [[PRelationship alloc] init];
    }
    
    return _demands;
}

- (PRelationship*)views {
    if (!_views) {
        _views = [[PRelationship alloc] init];
    }
    
    return _views;
}

#pragma mark Properties

- (NSString*)facebookId {
    return self.externalServices.facebook.userId;
}

- (NSString*)twitterId {
    return self.externalServices.twitter.userId;
}

- (NSString*)twitterHandle {
    return self.externalServices.twitter.username;
}

#pragma mark - Merging

- (void)mergeExternalServicesFromModel:(MTLModel*)model {
    PUser *user = (PUser*)model;
    if (user.externalServices) {
        [self.externalServices mergeValuesForKeysFromModel:user.externalServices];
    }
}

@end

@implementation PUser (SubjectiveObjectMeta)

- (void)addSubjectiveRelationshipsForResult:(PResult*)result {
    // TODO: Find a way to parse PResult's with the object
}

- (void)addSubjectiveRelationships:(PSubjectiveObjectMeta *)objectMeta forObject:(PObject*)object {
    PRelation *friendship = objectMeta.friendship;
    PRelation *demand = objectMeta.demand;
    PRelation *view = objectMeta.view;
    PRelation *like = objectMeta.like;
    
    if (friendship) {
        [PUser currentUser].friendships.set(object, friendship);
    }
    
    if (demand) {
        [PUser currentUser].demands.set(object, demand);
    }
    
    if (view) {
        [PUser currentUser].views.set(object, view);
    }
    
    if (like) {
        [PUser currentUser].likes.set(object, like);
    }
}

@end

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
        [PUser setCurrentUser:loggedInUser];
        
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
    _currentUser = nil;
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
            [_currentUser mergeValuesForKeysFromModel:result.user];
            
            [PUserContext currentContext].userResult.user = _currentUser;
            [[PUserContext currentContext] saveToDisk];
            
            if (success) {
                success(_currentUser);
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
        if (_demandedUsersCursor == 0) {
            [_demandedUsers removeAllObjects];
        }
        
        NSMutableArray *demandedUsers = [NSMutableArray arrayWithCapacity:results.count];
        for (PDemandResult *result in results) {
            PUser *user = result.demand.targetUserResult.user;
            [demandedUsers addObject:user];
            
            
            [[PUser currentUser] addSubjectiveRelationships:result.subjectiveObjectMeta forObject:user];
        }
        
        [_demandedUsers addObjectsFromArray:demandedUsers];
        
        if (success) {
            success(results, nextCursor);
        }
        
        _demandedUsersCursor = nextCursor;
    };
    
    return [PDemand getForwardDemandsForUser:self
                                     success:successBlock
                                     failure:failure];
}

- (NSURLSessionDataTask*)getDemandingUsersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (_demandingUsersCursor == 0) {
            [_demandingUsers removeAllObjects];
        }
        
        NSMutableArray *demandingUsers = [NSMutableArray arrayWithCapacity:results.count];
        for (PDemandResult *result in results) {
            PUser *user = result.demand.sourceUserResult.user;
            [demandingUsers addObject:user];
            
            [[PUser currentUser] addSubjectiveRelationships:result.subjectiveObjectMeta forObject:user];
        }
        
        [_demandingUsers addObjectsFromArray:demandingUsers];
        
        if (success) {
            success(results, nextCursor);
        }
        
        _demandingUsersCursor = nextCursor;
    };
    
    return [PDemand getBackwardDemandsForUser:self
                                      success:successBlock
                                      failure:failure];
}

- (NSURLSessionDataTask*)getLikedVideosWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (_likedVideosCursor == 0) {
            [_likedVideos removeAllObjects];
        }
        
        NSMutableArray *likedVideos = [NSMutableArray arrayWithCapacity:results.count];
        for (PLikeResult *result in results) {
            result.like.userResult = [[PUserResult alloc] init];
            result.like.userResult.user = self;
            
            PVideo *video = result.like.video;
            [likedVideos addObject:video];
            
            [[PUser currentUser] addSubjectiveRelationships:result.like.videoResult.subjectiveObjectMeta forObject:video];
        }
        
        [_likedVideos addObjectsFromArray:likedVideos];
        
        if (success) {
            success(likedVideos, nextCursor);
        }
        
        _likedVideosCursor = nextCursor;
    };
    
    return [PLike getLikedVideosForUser:self
                                success:successBlock
                                failure:failure];
}

- (NSURLSessionDataTask*)getVideosWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    PCollectionResultsBlock successBlock = ^(NSArray *results, NSInteger nextCursor) {
        if (_videosCursor == 0) {
            [_videos removeAllObjects];
        }
        
        NSMutableArray *videos = [NSMutableArray arrayWithCapacity:results.count];
        for (PVideoResult *result in results) {
            PVideo *video = result.video;
            video.creatorUser = [[PUserResult alloc] init];
            video.creatorUser.user = self;
            
            [videos addObject:video];
            
            [[PUser currentUser] addSubjectiveRelationships:result.subjectiveObjectMeta forObject:video];
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
        if (_followersCursor == 0) {
            [self.followers removeAllObjects];
        }
        
        NSMutableArray *followers = [NSMutableArray arrayWithCapacity:results.count];
        for (PFriendshipResult *result in results) {
            PUser *follower = result.friendship.sourceUser;
            [followers addObject:follower];
            
            [[PUser currentUser] addSubjectiveRelationships:result.subjectiveObjectMeta forObject:follower];
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
        if (_friendsCursor == 0) {
            [self.friends removeAllObjects];
        }
        
        NSMutableArray *friends = [NSMutableArray arrayWithCapacity:results.count];
        for (PFriendshipResult *result in results) {
            PUser *friend = result.friendship.targetUser;
            [friends addObject:friend];
                
            [[PUser currentUser] addSubjectiveRelationships:result.subjectiveObjectMeta forObject:friend];
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
                   [_currentUser mergeValuesForKeysFromModel:userResult.user];
                   
                   if (success) {
                       success(userResult);
                   }
               }
               failure:failure];
}

@end

#warning !!!: This category should be moved to an external file
@implementation PUser (Social)

- (NSString*)openGraphObjectKey {
    return @"user";
}

- (NSMutableDictionary<FBOpenGraphObject>*)openGraphObject {
    return [FBGraphObject openGraphObjectForPostWithType:@"presenttv:user"
                                                   title:self.username
                                                   image:self.profilePictureUrlString
                                                     url:nil
                                             description:self.userDescription];
}

- (void)demandOnFacebook {
    //[PSocialManager postObjectToFacebook:self withAction:PFacebookShareActionUserDemand];
}

- (void)linkedFacebookAccount {
    //[PSocialManager postObjectToFacebook:self withAction:PFacebookShareActionUserJoin];
}

@end

#warning !!!: This category should be moved to an external file
@implementation PUser (ExternalServices)

#pragma mark - Facebook

- (void)setFacebookData:(PFacebookData *)facebookData {
    if (![PFacebookData previouslyLinked]) {
        [self linkedFacebookAccount];
    }
    
    [PFacebookData setPreviouslyLinked];
    
    [self.externalServices.facebook mergeValuesForKeysFromModel:facebookData];
    [[PUserContext currentContext] saveToDisk];
}

- (void)clearFacebookData {
    [self.externalServices clearFacebookData];
    [[PUserContext currentContext] saveToDisk];
}

- (void)setShareLikesOnFacebook:(BOOL)shareLikes {
    self.externalServices.facebook.shareLikes = shareLikes;
    
    [[PUserContext currentContext] saveToDisk];
}

- (void)setShareDemandsOnFacebook:(BOOL)shareDemands {
    self.externalServices.facebook.shareDemands = shareDemands;
    
    [[PUserContext currentContext] saveToDisk];
}

- (void)setSharePostsOnFacebook:(BOOL)sharePosts {
    self.externalServices.facebook.sharePosts = sharePosts;
    
    [[PUserContext currentContext] saveToDisk];
}

#pragma mark - Twitter

- (void)setTwitterData:(PTwitterData *)twitterData {
    [PTwitterData setPreviouslyLinked];
    
    [self.externalServices.twitter mergeValuesForKeysFromModel:twitterData];
    [[PUserContext currentContext] saveToDisk];
}

- (void)clearTwitterData {
    [self.externalServices clearTwitterData];
    [[PUserContext currentContext] saveToDisk];
}

- (void)setSharePostsOnTwitter:(BOOL)sharePosts {
    self.externalServices.twitter.sharePosts = sharePosts;
    
    [[PUserContext currentContext] saveToDisk];
}

@end
