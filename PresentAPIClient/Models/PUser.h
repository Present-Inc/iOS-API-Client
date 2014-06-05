//
//  PUser.h
//  Present
//
//  Created by Justin Makaila on 11/14/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

#import "PFBOpenGraphProtocol.h"

@class PRelationship;
@class PExternalServices;
@class PUser;
@class PUserContext;
@class PLocation;
@class PFacebookData;
@class PTwitterData;

typedef void (^PUserBlock) (PUser *user, NSError *error);

@interface PUser : PObject <PObjectSubclassing>

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *displayUsername;

@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) NSString *userDescription;
@property (strong, nonatomic) NSString *gender;

@property (strong, nonatomic) NSString *profilePictureUrlString;

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *website;

@property (readonly, strong, nonatomic) NSString *facebookId;
@property (readonly, strong, nonatomic) NSString *twitterId;
@property (readonly, strong, nonatomic) NSString *twitterHandle;

@property (strong, nonatomic) PLocation *lastKnownLocation;
@property (strong, nonatomic) NSString *locationName;

@property (nonatomic) NSInteger followersCursor;
@property (strong, nonatomic) NSMutableArray *followers;

@property (nonatomic) NSInteger friendsCursor;
@property (strong, nonatomic) NSMutableArray *friends;

@property (nonatomic) NSInteger videosCursor;
@property (strong, nonatomic) NSMutableArray *videos;

@property (nonatomic) NSInteger likedVideosCursor;
@property (strong, nonatomic) NSMutableArray *likedVideos;

@property (nonatomic) NSInteger mentionedVideosCursor;
@property (strong, nonatomic) NSMutableArray *mentionedVideos;

@property (nonatomic) NSInteger demandingUsersCursor;
@property (strong, nonatomic) NSMutableArray *demandingUsers;

@property (nonatomic) NSInteger demandedUsersCursor;
@property (strong, nonatomic) NSMutableArray *demandedUsers;

@property (strong, nonatomic) PRelationship *friendships;
@property (strong, nonatomic) PRelationship *demands;
@property (strong, nonatomic) PRelationship *likes;

@property (nonatomic) NSInteger videoCount;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic) NSInteger friendCount;
@property (nonatomic) NSInteger followerCount;
@property (nonatomic) NSInteger demandCount;
@property (nonatomic) NSInteger viewCount;

@property (nonatomic) BOOL registrationComplete;
@property (nonatomic, getter = isAdmin) BOOL admin;

- (BOOL)isAuthenticated;
- (BOOL)isCurrentUser;

- (NSURL*)profilePictureURL;

- (void)toggleFriendship;
- (void)toggleDemand;

@end

@interface PUser (CurrentUser)

+ (PUser*)currentUser;
+ (void)setCurrentUser:(PUser*)user;

@end

@interface PUser (Social) <PFBOpenGraphProtocol>
- (void)demandOnFacebook;
@end

@interface PUser (ExternalServices)

@property (readonly, strong, nonatomic) PExternalServices *externalServices;

- (void)setFacebookData:(PFacebookData*)facebookData;
- (void)clearFacebookData;

- (void)setTwitterData:(PTwitterData*)twitterData;
- (void)clearTwitterData;

- (void)setShareLikesOnFacebook:(BOOL)shareLikes;
- (void)setShareDemandsOnFacebook:(BOOL)shareDemands;
- (void)setSharePostsOnFacebook:(BOOL)sharePosts;

- (void)setSharePostsOnTwitter:(BOOL)sharePosts;

@end
