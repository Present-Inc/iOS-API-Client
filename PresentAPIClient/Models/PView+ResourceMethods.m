//
//  PView+ResourceMethods.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 6/5/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PView+ResourceMethods.h"

#import "PVideo.h"
#import "PUser.h"

@implementation PView (ResourceMethods)

+ (NSString*)listUserViewsResource {
    return [self resourceWithString:@"list_user_forward_views"];
}

+ (void)createViewForVideo:(PVideo *)video success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *viewParameters = @{
        @"video_id": video._id
    };
    
    [PView post:[PView createResource]
 withParameters:viewParameters
        success:success
        failure:failure];
}

+ (void)getViewsForUser:(PUser *)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSDictionary *viewParameters = @{
        @"user_id": user._id
    };
    
    [PView post:[PView listUserViewsResource]
 withParameters:viewParameters
        success:success
        failure:failure];
}

@end
