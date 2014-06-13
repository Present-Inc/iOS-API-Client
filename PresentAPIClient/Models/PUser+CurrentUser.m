//
//  PUser+CurrentUser.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/5/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser+CurrentUser.h"
#import "PUserContext.h"
#import "PResult.h"

static PUser *_currentUser;

@implementation PUser (CurrentUser)

+ (PUser*)_currentUser {
    if (!_currentUser) {
        [self _setCurrentUser:[PUserContext currentContext].userResult.user];
    }
    
    return _currentUser;
}

+ (void)_setCurrentUser:(PUser*)user {
    _currentUser = user;
}

@end

