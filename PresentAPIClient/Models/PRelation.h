//
//  PRelation.h
//  PConnections
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

@interface PRelation : MTLModel <MTLJSONSerializing>

@property (readwrite, nonatomic) BOOL forward;
@property (readwrite, nonatomic) BOOL backward;

+ (instancetype)relationForward:(BOOL)forward backward:(BOOL)backward;

@end
