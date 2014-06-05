//
//  PLike.m
//  Present
//
//  Created by Justin Makaila on 3/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser.h"
#import "PLike.h"
#import "PVideo.h"
#import "PResult.h"

@implementation PLike

+ (NSString*)classResource {
    return @"likes";
}

+ (Class)resourceResultClass {
    return PLikeResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"sourceUserResult": @"sourceUser",
        @"targetVideoResult": @"targetVideo"
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

+ (NSValueTransformer*)targetVideoResultJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *dictionary) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            return [MTLJSONAdapter modelOfClass:PVideoResult.class fromJSONDictionary:dictionary error:nil];
        }else {
            return nil;
        }
    }];
}

+ (instancetype)likeForVideo:(PVideo *)video {
    PLike *like = [PLike object];
    
    like.sourceUserResult = [[PUserResult alloc] init];
    like.sourceUserResult.user = [PUser currentUser];
    
    like.targetVideoResult = [[PVideoResult alloc] init];
    like.targetVideoResult.video = video;
    like.targetVideoResult.subjectiveObjectMeta.like = [PRelation relationForward:YES backward:NO];
    
    return like;
}

- (PUser*)sourceUser {
    return self.sourceUserResult.user;
}

- (PVideo*)targetVideo {
    return self.targetVideoResult.video;
}

@end
