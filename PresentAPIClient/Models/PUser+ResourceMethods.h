//
//  PUser+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Networking.h"
#import "PUser.h"

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
