//
//  PExternalServices.m
//  Present
//
//  Created by Justin Makaila on 3/21/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PExternalServices.h"

#import <MTLValueTransformer.h>
#import <NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation PExternalServices

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"facebook": @"facebook",
        @"twitter": @"twitter"
    };
}

+ (NSValueTransformer*)facebookJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PFacebookData.class];
}

+ (NSValueTransformer*)twitterJSONTransformer {
    return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PTwitterData.class];
}

- (void)mergeFacebookFromModel:(MTLModel*)model {
    PExternalServices *externalServiceData = (PExternalServices*)model;
    
    if (externalServiceData.facebook) {
        [self.facebook mergeValuesForKeysFromModel:externalServiceData.facebook];
    }
}

- (void)mergeTwitterFromModel:(MTLModel*)model {
    PExternalServices *externalServiceData = (PExternalServices*)model;
    
    if (externalServiceData.twitter) {
        [self.twitter mergeValuesForKeysFromModel:externalServiceData.twitter];
    }
}

- (PFacebookData*)facebook {
    if (!_facebook) {
        _facebook = [[PFacebookData alloc] init];
    }
    
    return _facebook;
}

- (PTwitterData*)twitter {
    if (!_twitter) {
        _twitter = [[PTwitterData alloc] init];
    }
    
    return _twitter;
}

- (void)clearFacebookData {
    [self.facebook clearData];
}

- (void)clearTwitterData {
    [self.twitter clearData];
}

@end
