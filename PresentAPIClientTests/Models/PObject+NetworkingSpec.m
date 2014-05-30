//
//  PObject+NetworkingSpec.m
//  PresentAPIClient
//
//  Created by Justin Makaila on 5/29/14.
//  Copyright 2014 Present, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PObject+Networking.h"

#import "PVideo.h"


SPEC_BEGIN(PObject_NetworkingSpec)

describe(@"PObject+Networking", ^{
    it (@"can provide a resource route for any string", ^{
        [PObject stub:@selector(classResource) andReturn:@"classResource"];
        
        NSString *resourceString = [PObject resourceWithString:@"methodResource"];
        
        [[resourceString should] equal:@"classResource/methodResource"];
    });
});

SPEC_END
