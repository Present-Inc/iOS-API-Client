//
//  PObjectNetworking.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PObjectNetworking <NSObject>

+ (NSString*)classResource;
+ (Class)resourceResultClass;

/**
 *  A block for handling a collection of P<ClassResource>Result's
 *  and the nextCursor
 *
 *  @return void (^) (NSArray *, NSInteger) for handling a collection response
 */
+ (void (^) (NSArray *, NSInteger))collectionResultsBlockWithSuccess:(void (^) (NSArray *, NSInteger))success;

/**
 *  A block for handling a P<ClassResource>Result
 *
 *  @param success void (^) (id) block for handling a single resource response
 */
+ (void (^) (id object))resourceResultBlockWithSuccess:(void (^) (id object))success;

@end
