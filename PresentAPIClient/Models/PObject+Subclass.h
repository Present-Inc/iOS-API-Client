//
//  PObject+PObjectSubclassing.h
//  Present
//
//  Created by Justin Makaila on 3/21/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject.h"
#import "PObjectSubclassing.h"

@interface PObject (Subclass)

+ (instancetype)object;
+ (instancetype)objectWithObjectId:(NSString*)objectId;

@end
