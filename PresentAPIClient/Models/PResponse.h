//
//  PResponseObject.h
//  Present
//
//  Created by Justin Makaila on 3/17/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>

typedef NS_ENUM(NSInteger, PResponseStatus) {
    PResponseStatusOk,
    PResponseStatusError
};

@interface PResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic) PResponseStatus status;

@end

@interface PCollectionResponse : PResponse

@property (strong, nonatomic) NSArray *results;
@property (nonatomic) NSInteger nextCursor;

/**
 *  Returns an array of the PSubjectiveObjectMeta objects
 *  of each PResult in results
 *
 *  @return An array of PSubjectiveObjectMeta objects
 */
- (NSArray*)relationships;

/**
 *  Returns an array of each PObject within each
 *  PResult in results
 *
 *  @return An array of PObject's
 */
- (NSArray*)objects;

@end

@interface PResourceResponse : PResponse

@property (strong, nonatomic) NSDictionary *result;

@end

typedef NS_ENUM(NSInteger, PErrorCode) {
    // Auth
    PErrorCodeAuthIncorrectCredentials = 10001,
    PErrorCodeAuthMissingRequiredUserContext = 10002,
    
    //Account
    PErrorCodeAccountUsernameAlreadyExists = 20001,
    PErrorCodeAccountEmailAlreadyExists = 20002,
    
    // Request
    PErrorCodeRequestUnknownError = 30001,
    PErrorCodeRequestMissingRequiredHeader = 30002,
    PErrorCodeRequestMissingRequiredParameter = 30003,
    PErrorCodeRequestInvalidRequiredParameter = 30004,
    PErrorCodeRequestMissingRequiredFile = 30005,
    PErrorCodeRequestInvalidRequiredFile = 30006,
    PErrorCodeRequestExceededMaxLengthLimit = 30007,
    PErrorCodeRequestUploadFailed = 30008,
    
    // Service
    PErrorCodeServiceDatabaseError = 40001,
    PErrorCodeServiceS3Error = 40002,
    PErrorCodeServiceSNSError = 40003,
    
    // Video Append
    PErrorCodeVideoAppendFileSystemError = 50001,
    PErrorCodeVideoAppendConversionError = 50002,
};

@interface PErrorResponse : PResponse

@property (nonatomic) NSInteger code;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *stackTrace;

+ (instancetype)errorWithMessage:(NSString*)message;

@end
