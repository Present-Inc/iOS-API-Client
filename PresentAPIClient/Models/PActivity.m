//
//  PActivity.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PActivity.h"

#import "PResult.h"
#import <NSDictionary+MTLManipulationAdditions.h>

@implementation PActivity

+ (NSString*)classResource {
    return @"activities";
}

+ (Class)resourceResultClass {
    return PActivityResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"type": @"type",
        @"unread": @"isUnread",
        @"sourceUserResult": @"sourceUser",
        @"targetUserResult": @"targetUser",
        @"videoResult": @"video",
        @"commentResult": @"comment",
        @"subject": @"subject"
    }];
}

+ (NSValueTransformer*)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"newComment": @(PActivityTypeNewComment),
        @"newCommentMention": @(PActivityTypeNewCommentMention),
        @"newDemand": @(PActivityTypeNewDemand),
        @"newFollower": @(PActivityTypeNewFollower),
        @"newLike": @(PActivityTypeNewLike),
        @"newVideoByDemandedUser": @(PActivityTypeNewVideoByDemandedUser),
        @"newVideoByFriend": @(PActivityTypeNewVideoByFriend),
        @"newVideoMention": @(PActivityTypeNewVideoMention),
        @"newViewer": @(PActivityTypeNewViewer)
    }];
}

+ (NSValueTransformer*)sourceUserResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PUserResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)targetUserResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PUserResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)videoResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PVideoResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

+ (NSValueTransformer*)commentResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PCommentResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

- (PUser*)sourceUser {
    return self.sourceUserResult.user;
}

- (PUser*)targetUser {
    return self.targetUserResult.user;
}

- (PVideo*)video {
    return self.videoResult.video;
}

- (PComment*)comment {
    return self.commentResult.comment;
}

@end
