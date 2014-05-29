//
//  PMention.m
//  Present
//
//  Created by Justin Makaila on 2/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PMention.h"

@implementation PMention

+ (instancetype)mentionWithUser:(PUser *)user range:(NSRange)range {
    return[[PMention alloc] initWithUser:user range:range];
}

- (id)initWithUser:(PUser *)user range:(NSRange)range {
    self = [super init];
    if (self) {
        _user = user;
        _range = range;
    }
    
    return self;
}

- (NSValue*)rangeValue {
    return [NSValue valueWithRange:self.range];
}

@end
