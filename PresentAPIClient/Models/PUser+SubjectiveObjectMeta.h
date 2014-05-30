//
//  PUser+SubjectiveObjectMeta.h
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUser.h"

@class PSubjectiveObjectMeta;
@class PResult;

@interface PUser (SubjectiveObjectMeta)
- (void)addSubjectiveRelationshipsForResult:(PResult*)result;
- (void)addSubjectiveRelationships:(PSubjectiveObjectMeta*)objectMeta forObject:(PObject*)object;
@end
