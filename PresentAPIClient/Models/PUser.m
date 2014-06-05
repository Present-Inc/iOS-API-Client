//
//  PUser.m
//  Present
//
//  Created by Justin Makaila on 11/14/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PUser.h"
#import "PUser+SubjectiveObjectMeta.h"

#import "PRelationship.h"
#import "PFriendship+ResourceMethods.h"
#import "PLike.h"
#import "PUserContext.h"
#import "PDemand+ResourceMethods.h"
#import "PLocation.h"
#import "PVideo.h"
#import "PResult.h"
#import "PExternalServices.h"
#import "PSocialData.h"

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

@implementation PUser (CurrentUser)

+ (PUser*)currentUser {
    if (!_currentUser) {
        [self setCurrentUser:[PUserContext currentContext].userResult.user];
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(PUser*)user {
    _currentUser = user;
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
