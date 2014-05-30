//
//  PRelationship.m
//  PConnections
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PRelationship.h"

#import "PRelation.h"

@implementation PRelationship

- (id)init {
    return [super initWithClass:[PRelation class]];
}

- (BOOL (^)(id<PObjectProtocol>))from {
    return ^BOOL (id<PObjectProtocol> object) {
        return ((PRelation*)self.dictionary[object._id]).backward;
    };
}

- (BOOL (^)(id<PObjectProtocol>))to {
    return ^BOOL (id<PObjectProtocol> object) {
        return ((PRelation*)self.dictionary[object._id]).forward;
    };
}

- (PRelation* (^)(id<PObjectProtocol>))get {
    return ^(id<PObjectProtocol> object) {
        return self.dictionary[object._id];
    };
}

- (void (^)(id<PObjectProtocol>, PRelation *))set {
    return ^(id<PObjectProtocol> object, PRelation *relation) {
        self.dictionary[object._id] = relation;
    };
}

- (void (^)(id<PObjectProtocol>, BOOL))setForward {
    return ^(id<PObjectProtocol> object, BOOL value) {
        PRelation *relation = (PRelation*)self.dictionary[object._id];
        if (!relation) {
            relation = [[PRelation alloc] init];
            relation.forward = value;
            relation.backward = NO;
            
            self.dictionary[object._id] = relation;
        }else {
            relation.forward = value;
        }
    };
}

- (void (^)(id<PObjectProtocol>, BOOL))setBackward {
    return ^(id<PObjectProtocol> object, BOOL value) {
        PRelation *relation = (PRelation*)self.dictionary[object._id];
        if (!relation) {
            relation = [[PRelation alloc] init];
            relation.forward = NO;
            relation.backward = NO;
            
            self.dictionary[object._id] = relation;
        }else {
            relation.backward = value;
        }
    };
}

- (void (^) ())clear {
    return ^{
        [self.dictionary removeAllObjects];
    };
}

@end
