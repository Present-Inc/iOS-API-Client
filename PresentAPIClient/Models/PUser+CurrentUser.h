//
//  PUser+CurrentUser.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/5/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser.h"

@interface PUser (CurrentUser)

+ (PUser*)_currentUser;
+ (void)_setCurrentUser:(PUser*)user;

@end
