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

- (instancetype)initWithSubjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super init];
    if (self) {
        _subjectiveObjectMeta = objectMeta;
    }
    
    return self;
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
    }else if ([self isMemberOfClass:[PPlaceResult class]]) {
        return ((PPlaceResult*)self).place;
    }else if ([self isMemberOfClass:[PUserResult class]]) {
        return ((PUserResult*)self).user;
    }else if ([self isMemberOfClass:[PUserContextResult class]]) {
        return ((PUserContextResult*)self).userContext;
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

- (instancetype)initWithActivity:(PActivity *)activity {
    return [self initWithActivity:activity subjectiveObjectMeta:nil];
}

- (instancetype)initWithActivity:(PActivity *)activity subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _activity = activity;
    }
    
    return self;
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

- (instancetype)initWithComment:(PComment *)comment {
    return [self initWithComment:comment subjectiveObjectMeta:nil];
}

- (instancetype)initWithComment:(PComment *)comment subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _comment = comment;
    }
    
    return self;
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

- (instancetype)initWithDemand:(PDemand *)demand {
    return [self initWithDemand:demand subjectiveObjectMeta:nil];
}

- (instancetype)initWithDemand:(PDemand *)demand subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _demand = demand;
    }
    
    return self;
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

- (instancetype)initWithFriendship:(PFriendship *)friendship {
    return [self initWithFriendship:friendship subjectiveObjectMeta:nil];
}

- (instancetype)initWithFriendship:(PFriendship *)friendship subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _friendship = friendship;
    }
    
    return self;
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

- (instancetype)initWithLike:(PLike *)like {
    return [self initWithLike:like subjectiveObjectMeta:nil];
}

- (instancetype)initWithLike:(PLike *)like subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _like = like;
    }
    
    return self;
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

- (instancetype)initWithPlace:(PPlace *)place {
    return [self initWithPlace:place subjectiveObjectMeta:nil];
}

- (instancetype)initWithPlace:(PPlace *)place subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _place = place;
    }
    
    return self;
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

- (instancetype)initWithUser:(PUser *)user {
    return [self initWithUser:user subjectiveObjectMeta:nil];
}

- (instancetype)initWithUser:(PUser *)user subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _user = user;
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

- (instancetype)initWithUserContext:(PUserContext *)userContext {
    return [self initWithUserContext:userContext subjectiveObjectMeta:nil];
}

- (instancetype)initWithUserContext:(PUserContext *)userContext subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _userContext = userContext;
    }
    
    return self;
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

- (instancetype)initWithVideo:(PVideo *)video {
    return [self initWithVideo:video subjectiveObjectMeta:nil];
}

- (instancetype)initWithVideo:(PVideo *)video subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _video = video;
    }
    
    return self;
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

- (instancetype)initWithView:(PView *)view {
    return [self initWithView:view subjectiveObjectMeta:nil];
}

- (instancetype)initWithView:(PView *)view subjectiveObjectMeta:(PSubjectiveObjectMeta *)objectMeta {
    self = [super initWithSubjectiveObjectMeta:objectMeta];
    if (self) {
        _view = view;
    }
    
    return self;
}

@end

