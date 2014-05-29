//
//  PMention.h
//  Present
//
//  Created by Justin Makaila on 2/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import "PUser.h"

@interface PMention : MTLModel

@property (strong, nonatomic) PUser *user;
@property (nonatomic) NSRange range;

+ (instancetype)mentionWithUser:(PUser*)user range:(NSRange)range;

- (id)initWithUser:(PUser*)user range:(NSRange)range;

- (NSValue*)rangeValue;

@end
