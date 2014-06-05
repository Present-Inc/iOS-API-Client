//
//  PDemand+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PDemand+ResourceMethods.h"

#import "PUser.h"

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
        @"user_id": self.targetUser._id
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

