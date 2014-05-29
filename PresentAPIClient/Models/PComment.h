//
//  PComment.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"
#import "PObject+Networking.h"

@class PUser;
@class PVideo;
@class PUserResult;
@class PVideoResult;

@interface PComment : PObject <PObjectSubclassing>

@property (strong, nonatomic) NSString *body;

@property (strong, nonatomic) PUserResult *sourceUser;
@property (strong, nonatomic) PVideoResult *targetVideo;

@property (strong, nonatomic) NSDate *createdAtPlaceholder;

+ (instancetype)commentWithBody:(NSString*)commentBody onVideo:(PVideo*)video;

@end

@interface PComment (ResourceMethods)

+ (NSURLSessionDataTask*)getCommentWithId:(NSString*)id success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (NSURLSessionDataTask*)getCommentsForVideo:(PVideo*)video success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure;

+ (NSURLSessionDataTask*)deleteComment:(PComment*)comment success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure;
- (NSURLSessionDataTask*)updateWithBody:(NSString*)newBody success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
