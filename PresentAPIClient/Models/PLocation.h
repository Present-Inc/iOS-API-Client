//
//  PLocation.h
//  Present
//
//  Created by Justin Makaila on 3/4/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

#import <CoreLocation/CLLocation.h>

@interface PLocation : MTLModel <MTLJSONSerializing>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *crossString;

@property (nonatomic) BOOL isReducedPrecision;

+ (instancetype)location;
+ (instancetype)locationWithLocation:(CLLocation*)location;
+ (instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate;
+ (instancetype)locationWithLatitude:(double)latitude longitude:(double)longitude;

- (BOOL)isEqual:(id)object;

- (CLLocationCoordinate2D)coordinate;
- (CLLocation*)location;

- (CGFloat)distanceInMilesTo:(PLocation*)location;
- (CGFloat)distanceInKilometersTo:(PLocation*)location;

- (NSString*)toString;

@end
