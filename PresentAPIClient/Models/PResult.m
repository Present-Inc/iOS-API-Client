//
//  PResponseResult.m
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PResult.h"

#import "PObject.h"
#import "PActivity.h"
#import "PComment.h"
#import "PDemand.h"
#import "PFriendship.h"
#import "PLike.h"
#import "PUser.h"
#import "PUserContext.h"
#import "PVideo.h"
#import "PPlaylistSession.h"
#import "PView.h"
#import "PPlace.h"

@implementation PResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"subjectiveObjectMeta": @"subjectiveObjectMeta"
    };
}

+ (NSValueTransformer*)subjectiveObjectMetaJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PSubjectiveObjectMeta.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    } reverseBlock:^id (PSubjectiveObjectMeta *objectMeta) {
        return nil;
    }];
}

- (PSubjectiveObjectMeta*)subjectiveObjectMeta {
    if (!_subjectiveObjectMeta) {
        _subjectiveObjectMeta = [[PSubjectiveObjectMeta alloc] init];
    }
    
    return _subjectiveObjectMeta;
}

/**
 *  Returns the object associated with the result. This is provided for dynamic access
 *  to all possible results from the cluster class.
 *
 *  @return The PObject stored in the result. If no object is found, returns nil
 */
- (PObject*)object {
    if ([self isMemberOfClass:[PActivityResult class]]) {
        return ((PActivityResult*)self).activity;
    }else if ([self isMemberOfClass:[PCommentResult class]]) {
        return ((PCommentResult*)self).comment;
    }else if ([self isMemberOfClass:[PDemandResult class]]) {
        return ((PDemandResult*)self).demand;
    }else if ([self isMemberOfClass:[PFriendshipResult class]]) {
        return ((PFriendshipResult*)self).friendship;
    }else if ([self isMemberOfClass:[PLikeResult class]]) {
        return ((PLikeResult*)self).like;
    }else if ([self isMemberOfClass:[PUserResult class]]) {
        return ((PUserResult*)self).user;
    }else if ([self isMemberOfClass:[PVideoResult class]]) {
        return ((PVideoResult*)self).video;
    }
    
    return nil;
}

@end

@implementation PActivityResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"activity": @"object"
    }];
}

+ (NSValueTransformer*)activityJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PActivity.class];
}

@end

@implementation PCommentResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"comment": @"object"
    }];
}

+ (NSValueTransformer*)commentJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PComment.class];
}

@end

@implementation PDemandResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"demand": @"object"
    }];
}

+ (NSValueTransformer*)demandJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PDemand.class];
}

@end

@implementation PFriendshipResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"friendship": @"object"
    }];
}

+ (NSValueTransformer*)friendshipJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PFriendship.class];
}

@end

@implementation PLikeResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"like": @"object"
    }];
}

+ (NSValueTransformer*)likeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PLike.class];
}

@end

@implementation PPlaceResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"place": @"object"
    }];
}

+ (NSValueTransformer*)placeJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PPlace.class];
}

@end

@implementation PUserResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"user": @"object"
    }];
}

+ (NSValueTransformer*)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PUser.class];
}

- (id)initWithUser:(PUser *)user subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super init];
    if (self) {
        _user = user;
        self.subjectiveObjectMeta = objectMeta;
    }
    
    return self;
}

@end

@implementation PUserContextResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"userContext": @"object"
    }];
}

+ (NSValueTransformer*)userContextJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PUserContext.class];
}

@end

@implementation PVideoResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"video": @"object",
        @"playlistSession": @"playlistSession"
    }];
}

+ (NSValueTransformer*)videoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PVideo.class];
}

+ (NSValueTransformer*)playlistSessionJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PPlaylistSession.class];
}

@end

@implementation PViewResult

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"view": @"object"
    }];
}

+ (NSValueTransformer*)viewJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PView.class];
}

@end

