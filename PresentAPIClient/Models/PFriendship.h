//
//  PFriendship.h
//  Present
//
//  Created by Justin Makaila on 3/20/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

@class PUser;
@class PUserResult;

@interface PFriendship : PObject <PObjectSubclassing>

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PUserResult *targetUserResult;

+ (instancetype)friendshipWithUser:(PUser*)user;

- (PUser*)sourceUser;
- (PUser*)targetUser;

@end
