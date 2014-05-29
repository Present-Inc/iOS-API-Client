//
//  PObjectSubclassing.h
//  Present
//
//  Created by Justin Makaila on 3/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PObjectSubclassing <NSObject>

/**
 *  Returns a newly initialized PObject
 *
 *  @return A newly initialized PObject with
 *  no objectId, no createdAt, and no updatedAt
 */
+ (instancetype)object;

/**
 *  Returns a newly initialized PObject with an objectId
 *
 *  @param objectId The objectId for the PObject
 *
 *  @return A newly initialized PObject with
 *  no createdAt and no updatedAt properties
 */
+ (instancetype)objectWithObjectId:(NSString*)objectId;

@end
