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
        @"fromUserResult": @"sourceUser",
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

+ (NSValueTransformer*)fromUserResultJSONTransformer {
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

@end

@implementation PActivity (ResourceMethods)

+ (NSString*)listMyActivityResource {
    return [PActivity resourceWithString:@"list_my_activities"];
}

+ (NSString*)batchUpdateResource {
    return [PActivity resourceWithString:@"batch_update"];
}

+ (NSURLSessionDataTask*)getActivityForCurrentUserWithCursor:(NSInteger)cursor success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *activityParameters = [NSMutableDictionary dictionary];
    if (cursor > 0) {
        [activityParameters setObject:@(cursor) forKey:@"cursor"];
    }
    
    return [PActivity getCollectionAtResource:[PActivity listMyActivityResource]
                               withParameters:activityParameters
                                      success:success
                                      failure:failure];
}

+ (NSURLSessionDataTask*)saveActivityCollection:(NSArray *)collection success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableArray *ids = [NSMutableArray array];
    for (PActivity *activity in collection) {
        [ids addObject:activity._id];
    }
    
    NSMutableDictionary *activityParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"activity_ids": ids,
        @"is_unread": @(NO)
    }];
    
    return [PActivity postCollection:[self batchUpdateResource]
                      withParameters:activityParameters
                             success:success
                             failure:failure];
}

@end
