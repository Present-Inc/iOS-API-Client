//
//  PObjectSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PObject.h"


SPEC_BEGIN(PObjectSpec)

describe(@"PObject", ^{
    it (@"can indicate if an object is new (has never been saved)", ^{
        PObject *object = [[PObject alloc] init];
        
        [[theValue(object.isNew) should] beYes];
    });
    
    it (@"can indicate if two objects are equal via clientId", ^{
        PObject *objectOne = [[PObject alloc] init];
        objectOne.clientId = @"123";
        
        PObject *objectTwo = [[PObject alloc] init];
        objectTwo.clientId = @"123";
        
        [[theValue([objectOne isEqual:objectTwo]) should] beYes];
        
        objectTwo.clientId = @"456";
        
        [[theValue([objectOne isEqual:objectTwo]) should] beNo];
    });
});

SPEC_END
