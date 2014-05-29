//
//  PUserContext.m
//  Present
//
//  Created by Justin Makaila on 3/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PUserContext.h"

#import "PResult.h"

#import <PFileManager.h>

@interface PUserContext ()

@property (strong, nonatomic) NSData *deviceToken;

+ (NSString*)stringForDeviceToken;

@end

static NSString *const CurrentUserContextArchivePath = @"UserContext";

static PUserContext *_currentContext = nil;
static NSData *_deviceToken = nil;

@implementation PUserContext

+ (NSString *)classResource {
    return @"user_contexts";
}

+ (Class)resourceResultClass {
    return PUserContextResult.class;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
        @"sessionToken": @"sessionToken",
        @"userResult": @"user"
    };
}

+ (NSValueTransformer*)userResultJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:PUserResult.class];
}

+ (PUserContext*)currentContext {
    if (!_currentContext) {
        _currentContext = [PFileManager loadObjectFromLocation:CurrentUserContextArchivePath inSearchPathDirectory:NSLibraryDirectory];
    }
    
    return _currentContext;
}

+ (NSDictionary*)pushCredentials {
    NSString *notificationPlatform;
#if DEBUG == 1
    notificationPlatform = @"APNS_SANDBOX";
#else
    notificationPlatform = @"APNS";
#endif
    
    NSString *deviceToken = [self stringForDeviceToken];
    if (deviceToken) {
        return @{
            @"device_identifier": deviceToken,
            @"push_notification_platform": notificationPlatform
        };
    }else {
        return nil;
    }
}

+ (void)setDeviceToken:(NSData*)token {
    _deviceToken = token;
    
    if (_currentContext) {
        [self updateDeviceIdentifier];
    }
}

+ (NSString*)stringForDeviceToken {
#warning !!!: This is not future proof, may change in future versions of iOS
    NSString *deviceTokenString = [_deviceToken description];
    deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return deviceTokenString;
}

- (void)saveToDisk {
    [PFileManager saveObject:self toLocation:CurrentUserContextArchivePath inSearchPathDirectory:NSLibraryDirectory];
}

@end

@implementation PUserContext (ResourceMethods)

+ (NSURLSessionDataTask*)authenticateWithCredentials:(NSDictionary *)credentials success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    PObjectResultBlock successBlock = ^(PUserContextResult *result) {
        PUserContext *userContext = result.userContext;
        [[PAPIManager sharedManager] setUserContext:userContext];
        
        _currentContext = userContext;
        [userContext saveToDisk];
        
        if (success) {
            success(userContext);
        }
    };
    
    NSDictionary *pushCredentials = [self pushCredentials];
    if (pushCredentials) {
        credentials = [credentials mtl_dictionaryByAddingEntriesFromDictionary:pushCredentials];
    }
    
    return [PUserContext post:[self createResource]
               withParameters:credentials
                      success:successBlock
                      failure:failure];
}

+ (NSURLSessionDataTask*)updateDeviceIdentifier {
    return [PUserContext post:[self updateResource]
               withParameters:[self pushCredentials]
                      success:nil
                      failure:nil];
}

+ (void)logOut {
    PObjectResultBlock successBlock = ^(id __unused object) {
        [[PAPIManager sharedManager] clearUserContext];
    };
    
    [PUserContext post:[self destroyResource]
        withParameters:nil
               success:successBlock
               failure:nil];
    
    _currentContext = nil;
    
    [PFileManager deleteFile:CurrentUserContextArchivePath inSearchPathDirectory:NSLibraryDirectory];
}

@end
