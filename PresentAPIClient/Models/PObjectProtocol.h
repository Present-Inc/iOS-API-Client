//
//  PObjectProtocol.h
//  Present
//
//  Created by Justin Makaila on 3/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PObjectProtocol <NSObject>

/**
 *  An objectId representing the model in the API
 */
@property (readonly, strong, nonatomic) NSString *_id;

/**
 *  An identifier to be set by the developer to identifiy
 *  an object before being saved to the API. If the object
 *  has been saved, this object will be equal to objectId
 */
@property (strong, nonatomic) NSString *clientId;

/**
 *  The date when the object was created
 */
@property (readonly, strong, nonatomic) NSDate *creationDate;

/**
 *  The date when the object was updated
 */
@property (readonly, strong, nonatomic) NSDate *lastUpdatedAt;

@end
