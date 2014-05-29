//
//  PObject.h
//  Present
//
//  Created by Justin Makaila on 3/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import "PObjectProtocol.h"

/**
 *  The base class for API objects
 */
@interface PObject : MTLModel <MTLJSONSerializing, PObjectProtocol>

/**
 *  The ID of the object in the DB
 */
@property (readonly, strong, nonatomic) NSString *_id;

/**
 *  An ID to be used on the client side
 *
 *  @discussion Typically used for unsaved objects
 */
@property (strong, nonatomic) NSString *clientId;

/**
 *  The date that the object was created in the DB
 */
@property (readonly, strong, nonatomic) NSDate *creationDate;

/**
 *  The date when the object was last updated in the DB
 */
@property (readonly, strong, nonatomic) NSDate *lastUpdatedAt;

/**
 *  The value transformer to be used for all NSDate properties
 *
 *  @return A NSValueTransformer for JSON <-> NSDate
 */
+ (NSValueTransformer*)dateTransformer;

/**
 *  Compares object with the reciever
 *
 *  @param object The object to compare
 *
 *  @return YES if objectId and class is equal, else NO
 */
- (BOOL)isEqual:(id)object;

/**
 *  Indicates whether the object has been saved to the
 *  API before
 *
 *  @return YES if the object has been saved, else NO
 */
- (BOOL)isNew;

@end
