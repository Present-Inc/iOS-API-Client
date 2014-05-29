//
//  PDictionary.m
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PDictionary.h"

@implementation PDictionary

- (id)initWithClass:(Class)class {
    self = [super init];
    if (self) {
        __objectClass = class;
        _dictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionaryWithCapacity:capacity];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionaryWithDictionary:otherDictionary];
    }
    
    return self;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if ([anObject isKindOfClass:__objectClass]) {
        [_dictionary setObject:anObject forKey:aKey];
    }else {
        [[NSException exceptionWithName:@"kInvalidObjectException"
                                 reason:[NSString stringWithFormat:@"An object is not of the %@ class", __objectClass]
                               userInfo:nil] raise];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:__objectClass]) {
        [_dictionary setValue:value forKey:key];
    }else {
        [[NSException exceptionWithName:@"kInvalidValueException"
                                 reason:[NSString stringWithFormat:@"A value is not of the class %@", __objectClass]
                               userInfo:nil] raise];
    }
}

- (void)removeObjectForKey:(id)aKey {
    [_dictionary removeObjectForKey:aKey];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    [_dictionary removeObjectsForKeys:keyArray];
}

- (NSUInteger)count {
    return _dictionary.count;
}

- (Class)objectForKey:(id)aKey {
    return (Class)[_dictionary objectForKey:aKey];
}

- (NSEnumerator*)keyEnumerator {
    return _dictionary.keyEnumerator;
}

@end
