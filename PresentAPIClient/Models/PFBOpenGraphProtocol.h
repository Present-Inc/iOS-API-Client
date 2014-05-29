//
//  PObjectSocialProtocol.h
//  Present
//
//  Created by Justin Makaila on 4/15/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBOpenGraphObject.h>

@protocol PFBOpenGraphProtocol <NSObject>

- (NSString*)openGraphObjectKey;
- (NSMutableDictionary<FBOpenGraphObject>*)openGraphObject;

@end
