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

@implementation PDemand (ResourceMethods)

+ (NSString*)forwardDemandResource {
    return [self resourceWithString:@"list_user_forward_demands"];
}

+ (NSString*)backwardDemandResource {
    return [self resourceWithString:@"list_user_backward_demands"];
}

+ (NSURLSessionDataTask*)deleteDemandForUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *demandParameters = @{
        @"user_id": user._id
    };
    
    return [PDemand post:[PDemand destroyResource]
          withParameters:demandParameters
                 success:success
                 failure:failure];
}

+ (NSURLSessionDataTask*)getForwardDemandsForUser:(PUser *)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *forwardDemandParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": user._id
    }];
    
    if (user.demandedUsersCursor > 0) {
        [forwardDemandParameters setObject:@(user.demandedUsersCursor) forKey:@"cursor"];
    }
    
    return [PDemand getCollectionAtResource:[PDemand forwardDemandResource]
                             withParameters:forwardDemandParameters
                                    success:success
                                    failure:failure];
}

+ (NSURLSessionDataTask*)getBackwardDemandsForUser:(PUser *)user success:(PCollectionResultsBlock)success failure:(PFailureBlock)failure {
    NSMutableDictionary *backwardDemandParameters = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id": user._id
    }];
    
    if (user.demandingUsersCursor > 0) {
        [backwardDemandParameters setObject:@(user.demandingUsersCursor) forKey:@"cursor"];
    }
    
    return [PDemand getCollectionAtResource:[PDemand backwardDemandResource]
                             withParameters:backwardDemandParameters
                                    success:success
                                    failure:failure];
}

- (NSURLSessionDataTask*)createWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *demandParameters = @{
        @"user_id": self.targetUserResult.user._id
    };
    
    return [PDemand post:[PDemand createResource]
          withParameters:demandParameters
                 success:success
                 failure:failure];
}

- (NSURLSessionDataTask*)deleteWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return [PDemand deleteDemandForUser:self.targetUser
                                success:success
                                failure:failure];
}

@end
