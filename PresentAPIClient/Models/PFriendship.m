//
//  PFriendship.m
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PFriendship.h"

#import "PUser.h"
#import "PResult.h"
#import "PRelationship.h"

@implementation PFriendship

+ (NSString*)classResource {
    return @"friendships";
}

+ (Class)resourceResultClass {
    return PFriendshipResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"sourceUserResult": @"sourceUser",
        @"targetUserResult": @"targetUser"
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

+ (instancetype)friendshipWithUser:(PUser *)user {
    PFriendship *friendship = [PFriendship object];
    friendship.sourceUserResult = [[PUserResult alloc] init];
    friendship.sourceUserResult.user = [PUser currentUser];
    
    [PUser currentUser].friendships.setForward(user, YES);
    
    friendship.targetUserResult = [[PUserResult alloc] init];
    friendship.targetUserResult.user = user;
    friendship.targetUserResult.subjectiveObjectMeta.friendship = [PUser currentUser].friendships.get(user);
    friendship.targetUserResult.subjectiveObjectMeta.demand = [PUser currentUser].demands.get(user);
    
    return friendship;
}

- (PUser*)sourceUser {
    return self.sourceUserResult.user;
}

- (PUser*)targetUser {
    return self.targetUserResult.user;
}

@end
