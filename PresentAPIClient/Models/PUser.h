//
//  PUser.h
//  Present
//
//  Created by Justin Makaila on 11/14/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

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

+ (PUser*)currentUser;

- (BOOL)isAuthenticated;
- (BOOL)isCurrentUser;

- (NSURL*)profilePictureURL;

- (void)toggleFriendship;
- (void)toggleDemand;

@end

@interface PUser (ResourceMethods)

+ (NSURLSessionDataTask*)loginWithUsername:(NSString*)username password:(NSString*)password success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)signUpWithUsername:(NSString*)username password:(NSString*)password email:(NSString*)email profilePicture:(UIImage*)image success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)requestPasswordResetForEmail:(NSString*)email success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (void)logOut;

+ (NSURLSessionDataTask*)getUserWithId:(NSString*)objectId success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getUserWithUsername:(NSString*)username success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getCurrentUserWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getBrandNewUsersWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getFeaturedUsersWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getPopularUsersWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)getContactsOnPresentMatchingPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails cursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getTwitterFriendsOnPresent:(NSArray*)twitterFriends withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getFacebookFriendsOnPresent:(NSArray*)facebookFriends withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getUsersMatchingQueryString:(NSString*)queryString withCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)getDemandedUsersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getDemandingUsersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getLikedVideosWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getVideosWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getFollowersWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)getFriendsWithSuccess:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)updateProperties:(NSDictionary*)properties success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)updateProfilePicture:(UIImage*)profilePicture success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

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
