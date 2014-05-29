//
//  PLocation.m
//  Present
//
//  Created by Justin Makaila on 3/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PLocation.h"

#import <MTLValueTransformer.h>

@implementation PLocation

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"latitude": @"lat",
        @"longitude": @"lng",
        @"address": @"address",
        @"city": @"city",
        @"state": @"state",
        @"country": @"country",
        @"countryCode": @"countryCode",
        @"postalCode": @"postalCode",
        @"crossStreet": @"crossStreet",
        @"isReducedPrecision": @"isReducedPrecision"
    };
}

+ (NSValueTransformer*)coordinateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSDictionary* coordinate) {
        NSLog(@"Coordinate: %@", coordinate);
        return nil;
    }reverseBlock:^NSDictionary * (id coordinate) {
        NSLog(@"Incoming coordinate: %@", coordinate);
        return [NSDictionary dictionary];
    }];
}

+ (instancetype)location {
    return [[PLocation alloc] init];
}

+ (instancetype)locationWithLocation:(CLLocation *)location {
    return [PLocation locationWithCoordinate:location.coordinate];
}

+ (instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [PLocation locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

+ (instancetype)locationWithLatitude:(double)latitude longitude:(double)longitude {
    return [[PLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (id)initWithLatitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        PLocation *location = (PLocation*)object;
        return (self.coordinate.latitude == location.coordinate.latitude && self.coordinate.longitude == location.coordinate.longitude);
    }
    
    return NO;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (CLLocation*)location {
    return [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
}

- (CGFloat)distanceInMilesTo:(PLocation*)location {
    return ([self distanceInKilometersTo:location] * 0.62137);
}

- (CGFloat)distanceInKilometersTo:(PLocation*)location {
    return ([[self location] distanceFromLocation:[location location]] / 1000);
}

- (NSString*)toString {
    return [NSString stringWithFormat:@"%f,%f", self.latitude, self.longitude];
}

@end
