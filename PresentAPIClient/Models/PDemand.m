//
//  PDemand.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PDemand.h"

#import "PUser.h"
#import "PResult.h"
#import "PRelationship.h"

@implementation PDemand

+ (NSString*)classResource {
    return @"demands";
}

+ (Class)resourceResultClass {
    return PDemandResult.class;
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

+ (instancetype)demandForUser:(PUser*)user {
    PDemand *demand = [PDemand object];
    demand.sourceUserResult = [[PUserResult alloc] init];
    demand.sourceUserResult.user = [PUser currentUser];
    
    demand.targetUserResult = [[PUserResult alloc] init];
    demand.targetUserResult.user = user;
    demand.targetUserResult.subjectiveObjectMeta.friendship = [PUser currentUser].friendships.get(user);
    demand.targetUserResult.subjectiveObjectMeta.demand = [PUser currentUser].demands.get(user);
    
    return demand;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        PDemand *demand = (PDemand*)object;
        return (([self.sourceUser isEqual:demand.sourceUser] && [self.targetUser isEqual:demand.targetUser]) || [super isEqual:object]);
    }
    
    return NO;
}

- (PUser*)sourceUser {
    return self.sourceUserResult.user;
}

- (PUser*)targetUser {
    return self.targetUserResult.user;
}

@end
