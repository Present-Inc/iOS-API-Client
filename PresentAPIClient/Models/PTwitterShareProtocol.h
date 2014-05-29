//
//  PTwitterShareProtocol.h
//  Present
//
//  Created by Justin Makaila on 4/17/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTwitterShareProtocol <NSObject>

- (NSString *)twitterShareString;
- (NSString *)twitterPostString;

@end
