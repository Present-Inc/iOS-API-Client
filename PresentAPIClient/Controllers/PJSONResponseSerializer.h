//
//  AFURLResponseSerialization.h
//  Present
//
//  Created by Justin Makaila on 3/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <AFNetworking/AFURLResponseSerialization.h>
#import "PResponse.h"

static NSString *const PErrorResponseKey = @"PResponseErrorObject";

@interface PJSONResponseSerializer : AFJSONResponseSerializer

@end
