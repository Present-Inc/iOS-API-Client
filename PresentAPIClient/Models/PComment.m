//
//  PComment.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PComment.h"

#import "PUser.h"
#import "PVideo.h"
#import "PResult.h"
#import "PRelationship.h"

@implementation PComment

+ (NSString*)classResource {
    return @"comments";
}

+ (Class)resourceResultClass {
    return PCommentResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"sourceUserResult": @"sourceUser",
        @"targetVideoResult": @"targetVideo",
        @"createdAtPlaceholder": NSNull.null
    }];
}

+ (NSValueTransformer*)sourceUserResultJSONTransformer {
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

+ (NSValueTransformer*)targetVideoResultJSONTransformer {
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
    
    comment.targetVideoResult = [[PVideoResult alloc] initWithVideo:video];
    comment.targetVideoResult.subjectiveObjectMeta.like = [PUser currentUser].likes.get(video);
    
    comment.sourceUserResult = [[PUserResult alloc] initWithUser:[PUser currentUser]];
    
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
    PVideoResult *targetVideoResult = model.targetVideoResult;
    if ([targetVideoResult isKindOfClass:[NSString class]]) {
        return;
    }else if (targetVideoResult != nil) {
        self.targetVideoResult = targetVideoResult;
    }
}

- (void)mergeSourceUserFromModel:(PComment*)model {
    PUserResult *sourceUserResult = model.sourceUserResult;
    if ([sourceUserResult isKindOfClass:[NSString class]]) {
        return;
    }else if (sourceUserResult != nil) {
        self.sourceUserResult = sourceUserResult;
    }
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        PComment *comment = (PComment*)object;
        return ([comment.body isEqualToString:self.body] && [comment.sourceUser isEqual:self.sourceUser] && ([comment.createdAtPlaceholder isEqualToDate:self.createdAtPlaceholder] ||[ comment.creationDate isEqualToDate:self.creationDate]));
    }else {
        return NO;
    }
}

- (NSComparisonResult)compare:(PComment*)comment {
    NSDate *creationDate = (!self.creationDate) ? self.createdAtPlaceholder : self.creationDate;
    NSDate *compareDate = (!comment.creationDate) ? comment.createdAtPlaceholder : comment.creationDate;
    
    return [creationDate compare:compareDate];
}

- (PUser*)sourceUser {
    return self.sourceUserResult.user;
}

- (PVideo*)targetVideo {
    return self.targetVideoResult.video;
}

@end
