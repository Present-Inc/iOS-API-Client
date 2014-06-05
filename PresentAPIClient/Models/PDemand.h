//
//  PDemand.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

@class PUser;
@class PUserResult;

@interface PDemand : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PUserResult *targetUserResult;

+ (instancetype)demandForUser:(PUser*)user;

- (BOOL)isEqual:(id)object;

- (PUser*)sourceUser;
- (PUser*)targetUser;

@end
