//
//  AFURLResponseSerialization.m
//  Present
//
//  Created by Justin Makaila on 3/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PJSONResponseSerializer.h"
#import "PResponse.h"

@implementation PJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
	id JSONObject = [super responseObjectForResponse:response data:data error:error];
    
	if (*error != nil) {
		NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
		if (data != nil) {
            NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (errorDictionary) {
                userInfo[PErrorResponseKey] = [MTLJSONAdapter modelOfClass:PErrorResponse.class fromJSONDictionary:errorDictionary error:nil];
            }
		}
        
		NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
		(*error) = newError;
	}
    
	return (JSONObject);
}
@end
