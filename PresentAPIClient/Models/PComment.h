//
//  PComment.h
//  Present
//
//  Created by Justin Makaila on 11/13/13.
//  Copyright (c) 2013 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

@class PUser;
@class PVideo;
@class PUserResult;
@class PVideoResult;

@interface PComment : PObject <PObjectSubclassing>

@property (strong, nonatomic) NSString *body;

@property (strong, nonatomic) PUserResult *sourceUserResult;
@property (strong, nonatomic) PVideoResult *targetVideoResult;

@property (strong, nonatomic) NSDate *createdAtPlaceholder;

+ (instancetype)commentWithBody:(NSString*)commentBody onVideo:(PVideo*)video;

- (PUser*)sourceUser;
- (PVideo*)targetVideo;

@end
