//
//  PView+ResourceMethods.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/5/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PView.h"

@interface PView (ResourceMethods)

+ (void)createViewForVideo:(PVideo*)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure;
+ (void)getViewsForUser:(PUser*)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end
