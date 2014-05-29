//
//  PComment.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PComment.h"

#import "PMention.h"
#import "PVideo.h"
#import "PResult.h"

@implementation PComment

+ (NSString*)classResource {
    return @"comments";
}

+ (Class)resourceResultClass {
    return PCommentResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"creator": @"sourceUser",
        @"video": @"targetVideo",
        @"createdAtPlaceholder": NSNull.null
    }];
}

+ (NSValueTransformer*)sourceUserJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PUserResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^id (PUserResult *userResult) {
        if ([userResult isKindOfClass:[PUserResult class]]) {
            return [MTLJSONAdapter JSONDictionaryFromModel:userResult];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)targetVideoJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PVideoResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^id (PVideoResult *videoResult) {
        if ([videoResult isKindOfClass:[PVideoResult class]]) {
            return [MTLJSONAdapter JSONDictionaryFromModel:videoResult];
        }else {
            return nil;
        }
    }];
}

+ (instancetype)commentWithBody:(NSString *)commentBody onVideo:(PVideo *)video {
    PComment *comment = [PComment object];
    comment.targetVideo = [[PVideoResult alloc] init];
    comment.targetVideo.video = video;
    comment.targetVideo.subjectiveObjectMeta.like = [PUser currentUser].likes.get(video);
    
    comment.sourceUser = [[PUserResult alloc] init];
    comment.sourceUser.user = [PUser currentUser];
    
    comment.createdAtPlaceholder = [NSDate date];
    
    comment.body = commentBody;
    
    return comment;
}

- (void)mergeClientIdForModel:(PComment*)model {
    if (!model.clientId) {
        return;
    }else {
        self.clientId = model.clientId;
    }
}

- (void)mergeTargetVideoFromModel:(PComment*)model {
    PVideoResult *targetVideo = model.targetVideo;
    if ([targetVideo isKindOfClass:[NSString class]]) {
        return;
    }else if (targetVideo != nil) {
        self.targetVideo = targetVideo;
    }
}

- (void)mergeSourceUserFromModel:(PComment*)model {
    PUserResult *sourceUser = model.sourceUser;
    if ([sourceUser isKindOfClass:[NSString class]]) {
        return;
    }else if (sourceUser != nil) {
        self.sourceUser = sourceUser;
    }
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        PComment *comment = (PComment*)object;
        return ([comment.body isEqualToString:self.body] && [comment.sourceUser.user isEqual:self.sourceUser.user] && ([comment.createdAtPlaceholder isEqualToDate:self.createdAtPlaceholder] ||[ comment.creationDate isEqualToDate:self.creationDate]));
    }else {
        return NO;
    }
}

- (NSComparisonResult)compare:(PComment*)comment {
    NSDate *creationDate = (!self.creationDate) ? self.createdAtPlaceholder : self.creationDate;
    NSDate *compareDate = (!comment.creationDate) ? comment.createdAtPlaceholder : comment.creationDate;
    
    return [creationDate compare:compareDate];
}

@end

@implementation PComment (ResourceMethods)

+ (NSString*)listVideoCommentsResource {
    return [self resourceWithString:@"list_video_comments"];
}

+ (NSURLSessionDataTask*)getCommentWithId:(NSString *)id success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *commentParameters = @{
        @"comment_id": id
    };
    
    return [PComment getResource:[PComment showResource]
                  withParameters:commentParameters
                         success:success
                         failure:failure];
}

+ (NSURLSessionDataTask*)getCommentsForVideo:(PVideo *)video success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *commentParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:video._id, @"video_id", nil];
    if (video.commentsCursor > 0) {
        [commentParameters setObject:@(video.commentsCursor) forKey:@"cursor"];
    }
    
    return [PComment getCollectionAtResource:[PComment listVideoCommentsResource]
                              withParameters:commentParameters
                                     success:success
                                     failure:failure];
}

+ (NSURLSessionDataTask*)deleteComment:(PComment *)comment success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *commentParameters = @{
        @"comment_id": comment._id
    };
    
    return [PComment post:[PComment destroyResource]
           withParameters:commentParameters
                  success:success
                  failure:failure];
}

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *createParameters = @{
        @"video_id": self.targetVideo.video._id,
        @"body": self.body
    };
    
    return [PComment post:[PComment createResource]
           withParameters:createParameters
                  success:success
                  failure:failure];
}

- (NSURLSessionDataTask*)updateWithBody:(NSString *)newBody success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *updateParameters = @{
        @"comment_id": self._id,
        @"body": newBody
    };
    
    return [PComment post:[PComment updateResource]
           withParameters:updateParameters
                  success:success
                  failure:failure];
}

@end
