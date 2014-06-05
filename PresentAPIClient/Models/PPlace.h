//
//  PPlace.h
//  Present
//
//  Created by Justin Makaila on 5/1/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PObject+Subclass.h"

@class PLocation;

@interface PPlace : PObject <PObjectSubclassing>

@property (strong, nonatomic) NSString *fourSquareVenueId;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) PLocation *location;

//@property (strong, nonatomic) PProfile *profile;
@property (nonatomic) NSInteger videosCount;
@property (strong, nonatomic) NSMutableArray *videos;

@end
