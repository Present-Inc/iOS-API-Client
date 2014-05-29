//
//  PDictionary.h
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A monomorphic dictionary
 */
@interface PDictionary : NSMutableDictionary

@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (nonatomic) Class _objectClass;

- (id)initWithClass:(Class)class;
- (id)initWithCapacity:(NSUInteger)capacity;

@end
