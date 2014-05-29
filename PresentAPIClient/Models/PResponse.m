//
//  PResponseObject.m
//  Present
//
//  Created by Justin Makaila on 3/17/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "PResponse.h"
#import "PResult.h"

@implementation PResponse

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"status": @"status"
    };
}

+ (NSValueTransformer*)statusJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"OK": @(PResponseStatusOk),
        @"ERROR": @(PResponseStatusError)
    }];
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
    if (JSONDictionary[@"result"]) {
        if ([JSONDictionary[@"result"] isKindOfClass:[NSString class]]) {
            return PErrorResponse.class;
        }else {
            return PResourceResponse.class;
        }
    }
    
    if (JSONDictionary[@"results"]) {
        return PCollectionResponse.class;
    }
    
    NSAssert(NO, @"No matching class for the JSON dictionary \"%@\"", JSONDictionary);
    return self;
}

@end

@implementation PCollectionResponse

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"results": @"results",
        @"nextCursor": @"nextCursor"
    }];
}

- (NSArray*)relationships {
    NSMutableArray *relationships = [NSMutableArray array];
    for (PResult *result in self.results) {
        [relationships addObject:result.subjectiveObjectMeta];
    }
    
    return relationships;
}

- (NSArray*)objects {
    NSMutableArray *objects = [NSMutableArray array];
    for (id result in self.results) {
        // TODO: Get the object stored in the class's !subjectiveObjectMeta && isSubclassOf:[PObject class] property
        unsigned int numberOfProperties, i;
        objc_property_t *properties = class_copyPropertyList([result class], &numberOfProperties);
        for (i = 0; i < numberOfProperties; i++) {
            objc_property_t property = properties[i];
            
            const char *propertyName = property_getName(property);
            const char *propertyType = property_getAttributes(property);
            
            NSLog(@"%s is a %s", propertyName, propertyType);
        }
        
        free(properties);
    }
    
    return objects;
}

@end

@implementation PResourceResponse

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"result": @"result"
    }];
}

@end

@implementation PErrorResponse

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"message": @"result",
        @"code": @"errorCode",
        @"description": @"errorInfo.description",
        @"stackTrace": @"errorInfo.stack"
    }];
}

+ (instancetype)errorWithMessage:(NSString*)message {
    PErrorResponse *error = [[PErrorResponse alloc] init];
    error.status = PResponseStatusError;
    error.message = message;
    
    return error;
}

@end
