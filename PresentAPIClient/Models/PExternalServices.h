//
//  PExternalServices.h
//  Present
//
//  Created by Justin Makaila on 3/21/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import "PSocialData.h"

@interface PExternalServices : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) PFacebookData *facebook;
@property (strong, nonatomic) PTwitterData *twitter;

- (void)clearFacebookData;
- (void)clearTwitterData;

@end
