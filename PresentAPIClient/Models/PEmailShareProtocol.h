//
//  PEmailShareProtocol.h
//  Present
//
//  Created by Justin Makaila on 4/17/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PEmailShareProtocol <NSObject>

- (NSString*)emailSubject;
- (NSString*)emailBody;

@end
