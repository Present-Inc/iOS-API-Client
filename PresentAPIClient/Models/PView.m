//
//  PView.m
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PView.h"
#import "PUser.h"
#import "PVideo.h"
#import "PResult.h"

@implementation PView

+ (NSString*)classResource {
    return @"views";
}

+ (Class)resourceResultClass {
    return PViewResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"sourceUser": @"sourceUser",
        @"targetVideo": @"targetVideo"
    };
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        PView *view = (PView*)object;
        return ([self.videoResult.video isEqual:view.videoResult.video] && [self.userResult.user isEqual:view.userResult.user]);
    }
    
    return NO;
}

- (PUser*)user {
    return self.userResult.user;
}

- (PVideo*)video {
    return self.videoResult.video;
}

@end
