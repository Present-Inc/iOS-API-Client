//
//  PVideoSessionMeta.m
//  Present
//
//  Created by Justin Makaila on 2/27/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PVideoSessionMeta.h"

@implementation PVideoSessionMeta

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"fileNumber": @"fileNumber",
        @"completedUploads": @"completedUploads",
        @"failedUploads": @"failedUploads",
        @"createRetryCount": @"createRetryCount"
    };
}

- (NSInteger)totalUploads {
    return (self.fileNumber - self.failedUploads);
}

- (BOOL)finishedUploads {
    return (self.completedUploads >= self.totalUploads);
}

@end
