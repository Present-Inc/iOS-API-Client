//
//  PSocialData.h
//  Present
//
//  Created by Justin Makaila on 4/22/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface PSocialData : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *accountIdentifier;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *username;

+ (BOOL)previouslyLinked;
+ (void)setPreviouslyLinked;

- (void)clearData;

@end

@interface PFacebookData : PSocialData

@property (nonatomic) BOOL shareLikes;
@property (nonatomic) BOOL shareDemands;
@property (nonatomic) BOOL sharePosts;

+ (instancetype)facebookDataWithIdentifier:(NSString*)identifier userId:(NSString*)userId username:(NSString*)username;

@end

@interface PTwitterData : PSocialData

@property (nonatomic) BOOL sharePosts;

+ (instancetype)twitterDataWithIdentifier:(NSString*)identifier userId:(NSString*)userId username:(NSString*)username;

@end
