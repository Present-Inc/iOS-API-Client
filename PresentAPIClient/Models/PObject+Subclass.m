//
//  PObject+PObjectSubclassing.m
//  Present
//
//  Created by Justin Makaila on 3/21/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

@interface PObject (Private) <PObjectSubclassing>

- (id)initWithObjectId:(NSString*)objectId;

@property (strong, nonatomic) NSString *_id;

@end

@implementation PObject (Subclass)

+ (instancetype)object {
    return [[[self class] alloc] init];
}

+ (instancetype)objectWithObjectId:(NSString *)objectId {
    return [[[self class] alloc] initWithObjectId:objectId];
}

- (id)initWithObjectId:(NSString *)objectId {
    self = [super init];
    if (self) {
        self._id = objectId;
    }
    
    return self;
}

@end
