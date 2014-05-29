//
//  PSocialData.m
//  Present
//
//  Created by Justin Makaila on 4/22/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PSocialData.h"

@class PFacebookData;
@class PTwitterData;

@interface PSocialData ()

@property (assign, nonatomic) BOOL previouslyLinked;

@end

@implementation PSocialData

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"userId": @"userId",
        @"username": @"username",
        @"accountIdentifier": @"accountIdentifier",
    };
}

+ (BOOL)previouslyLinked {
    NSAssert(NO, @"+previouslyLinked should be called on PSocialData subclasses");
    return NO;
}

+ (void)setPreviouslyLinked {
    NSAssert(NO, @"+setPreviouslyLinked should be called on PSocialData subclasses");
}

- (void)mergeValueForKey:(NSString *)key fromModel:(MTLModel *)model {
    if ([key isEqualToString:@"shareLikes"] ||
        [key isEqualToString:@"sharePosts"] ||
        [key isEqualToString:@"shareDemands"]) {
        return;
    }
    
    [super mergeValueForKey:key fromModel:model];
}

- (void)mergeUsernameFromModel:(MTLModel*)model {
    PFacebookData *facebookData = (PFacebookData*)model;
    if (!facebookData.username) {
        return;
    }else {
        self.username = facebookData.username;
    }
}

- (void)mergeAccountIdentifierFromModel:(MTLModel*)model {
    PFacebookData *facebookData = (PFacebookData*)model;
    if (!facebookData.accountIdentifier) {
        return;
    }else if (!self.accountIdentifier && facebookData.accountIdentifier) {
        self.accountIdentifier = facebookData.accountIdentifier;
    }
}

- (void)clearData {
    self.accountIdentifier = nil;
    self.username = nil;
    self.userId = nil;
}

@end

@implementation PFacebookData

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [super JSONKeyPathsByPropertyKey];
}

+ (instancetype)facebookDataWithIdentifier:(NSString *)identifier userId:(NSString *)userId username:(NSString *)username {
    PFacebookData *data = [[PFacebookData alloc] init];
    data.accountIdentifier = identifier;
    data.userId = userId;
    data.username = username;
    
    data.shareDemands = NO;
    data.shareLikes = NO;
    data.sharePosts = NO;
    
    return data;
}

+ (BOOL)previouslyLinked {
    BOOL previouslyLinked = [[[NSUserDefaults standardUserDefaults] objectForKey:@"previouslyLinkedFacebook"] boolValue];
    NSLog(@"Has previously linked Facebook? %@", previouslyLinked ? @"YES" : @"NO");
    return previouslyLinked;
}

+ (void)setPreviouslyLinked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"previouslyLinkedFacebook"];
}

@end

@implementation PTwitterData

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [super JSONKeyPathsByPropertyKey];
}

+ (instancetype)twitterDataWithIdentifier:(NSString *)identifier userId:(NSString *)userId username:(NSString *)username {
    PTwitterData *data = [[PTwitterData alloc] init];
    data.accountIdentifier = identifier;
    data.userId = userId;
    data.username = username;
    
    data.sharePosts = NO;
    
    return data;
}

+ (BOOL)previouslyLinked {
    BOOL previouslyLinked = [[[NSUserDefaults standardUserDefaults] objectForKey:@"previouslyLinkedTwitter"] boolValue];
    return previouslyLinked;
}

+ (void)setPreviouslyLinked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"previouslyLinkedTwitter"];
}

@end
