//
//  PRelationship.h
//  PConnections
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PDictionary.h"

#import "PObjectProtocol.h"
#import "PRelation.h"

@interface PRelationship : PDictionary

/**
 *  Gets the backward relationship stored in key object.objectId
 */
@property (readonly, copy, nonatomic) BOOL (^from) (id<PObjectProtocol> object);

/**
 *  Gets the forward relationship stored in key object.objectId
 */
@property (readonly, copy, nonatomic) BOOL (^to) (id<PObjectProtocol> object);

@property (readonly, copy, nonatomic) PRelation* (^get) (id<PObjectProtocol>object);

@property (readonly, copy, nonatomic) void (^set) (id<PObjectProtocol> object, PRelation *relation);

/**
 *  Sets the forward relationship store in key object.objectId
 */
@property (readonly, copy, nonatomic) void (^setForward) (id<PObjectProtocol> object, BOOL value);

/**
 *  Sets the backward relationship store in key object.objectId
 */
@property (readonly, copy, nonatomic) void (^setBackward) (id<PObjectProtocol> object, BOOL value);

@end
