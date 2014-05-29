//
//  PSubjectiveObjectMeta.h
//  Present
//
//  Created by Justin Makaila on 3/24/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import "PRelation.h"

@interface PSubjectiveObjectMeta : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) PRelation *like;
@property (strong, nonatomic) PRelation *demand;
@property (strong, nonatomic) PRelation *friendship;
@property (strong, nonatomic) PRelation *view;

@end
