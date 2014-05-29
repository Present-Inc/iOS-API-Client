//
//  PSocialManager.h
//  Present
//
//  Created by Justin Makaila on 4/17/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@class PObject;
#import "PObject+Networking.h"

@class PFacebookManager;
@class PTwitterManager;

#import "PSMSShareProtocol.h"
#import "PEmailShareProtocol.h"
#import "PFBOpenGraphProtocol.h"
#import "PTwitterShareProtocol.h"

typedef NS_ENUM(NSInteger, PSocialAccountTypeIdentifier) {
    PSocialAccountTypeIdentifierFacebook,
    PSocialAccountTypeIdentifierTwitter
};

@interface PSocialManager : NSObject

@property (strong, nonatomic) PFacebookManager *facebookManager;
@property (strong, nonatomic) PTwitterManager *twitterManager;

+ (void)start;

+ (BOOL)currentUserIsLinkedWithAccount:(PSocialAccountTypeIdentifier)accountIdentifier;
+ (void)linkCurrentUserToAccountType:(PSocialAccountTypeIdentifier)accountIdentifier success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (void)requestAccessToAccountType:(PSocialAccountTypeIdentifier)accountIdentifier success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

+ (void)showComposeControllerForAccountType:(PSocialAccountTypeIdentifier)accountIdentifier withMessage:(NSString*)message url:(NSURL*)url success:(PObjectResultBlock)success failure:(PFailureBlock)failure;

@end

typedef NS_ENUM(NSInteger, PFacebookShareAction) {
    PFacebookShareActionShare,
    
    PFacebookShareActionVideoLike,
    PFacebookShareActionVideoPost,
    
    PFacebookShareActionUserDemand,
    PFacebookShareActionUserJoin
};

@interface PSocialManager (PFacebookManager)

+ (void)postObjectToFacebook:(PObject<PFBOpenGraphProtocol>*)object withAction:(PFacebookShareAction)action;

@end

typedef NS_ENUM(NSInteger, PTwitterShareAction) {
    PTwitterShareActionShare,
    PTwitterShareActionPost
};

@interface PSocialManager (PTwitterManager)

+ (void)postObjectToTwitter:(PObject<PTwitterShareProtocol>*)object withAction:(PTwitterShareAction)action;

@end

@interface PSocialManager (SMS) <MFMessageComposeViewControllerDelegate>

+ (void)showMFMessageComposeViewControllerForObject:(id<PSMSShareProtocol>)object;
+ (void)showMFMessageComposeViewControllerWithText:(NSString*)text;

@end

@interface PSocialManager (Email) <MFMailComposeViewControllerDelegate>

+ (void)showMFMailComposeViewControllerForObject:(id<PEmailShareProtocol>)object;
+ (void)showMFMailComposeViewControllerWithSubjectLine:(NSString*)subject messageBody:(NSString*)messageBody recipients:(NSArray*)recipients;

@end

static NSString *const PSocialManagerErrorDomain = @"PSocialManagerErrorDomain";
