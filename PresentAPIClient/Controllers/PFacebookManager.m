//
//  PFacebookManager.m
//  Present
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PFacebookManager.h"

#import <Social/Social.h>

@interface PFacebookManager () {
    NSArray *facebookAccounts;
}

@end

static ACAccount *_currentAccount;

@implementation PFacebookManager

+ (FBSession*)session {
    return [FBSession activeSession];
}

+ (PFacebookManager*)sharedManager {
    static PFacebookManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PFacebookManager alloc] init];
    });
    
    return sharedManager;
}

+ (ACAccount*)currentAccount {
    if (!_currentAccount) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        PFacebookData *authData = [PUser currentUser].externalServices.facebook;
        _currentAccount = [accountStore accountWithIdentifier:authData.accountIdentifier];
    }
    
    return _currentAccount;
}

+ (void)initializeFacebook {
    [self sharedManager];
}

+ (void)start {
    if ([self currentAccount]) {
        [[self sharedManager] loginWithAccount:_currentAccount];
    }
}

+ (BOOL)isLinkedWithUser:(PUser*)user {
    return !![self currentAccount];
}

+ (void)linkUser:(PUser *)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    [[self sharedManager] requestAccessToFacebookAccountsWithSuccess:success failure:failure];
}

+ (void)unlinkUser:(PUser *)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    if ([FBSession activeSession].state == FBSessionStateOpen || [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    
    [[PUser currentUser] clearFacebookData];
    _currentAccount = nil;
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(@YES);
        });
    }
    
    return;
}

+ (void)requestPublishPermissionsWithSuccess:(void(^)())success {
    void (^requestPermissionsBlock) () = ^{
        [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                defaultAudience:FBSessionDefaultAudienceEveryone
                                              completionHandler:^(FBSession *session, NSError *error) {
                                                  if (!error) {
                                                      if ([[FBSession activeSession].permissions indexOfObject:@"publish_actions"] == NSNotFound) {
                                                          [self showMessage:@"Your action will not be published to Facebook." withTitle:@"Permission not granted"];
                                                      }else {
                                                          success();
                                                      }
                                                  }else {
                                                      NSLog(@"An error occurred: %@", error);
                                                  }
                                              }];
    };
    
    if ([FBSession activeSession].state == FBSessionStateClosed) {
        [[self sharedManager] requestAccessToFacebookAccountsWithSuccess:^(id object) {
            requestPermissionsBlock();
        }failure:^(NSError *error) {
            NSLog(@"An error occurred requesting access to Facebook accounts");
        }];
    }else {
        requestPermissionsBlock();
    }
}

+ (FBSessionStateHandler)sessionCompletionHandlerWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    return ^(FBSession *session, FBSessionState state, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && state == FBSessionStateOpen) {
                NSLog(@"Session opened");
            }
            
            if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
                NSLog(@"Session closed");
            }
            
            if (error) {
                NSLog(@"Error");
                NSString *alertText;
                NSString *alertTitle;

                if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                    alertTitle = @"Something went wrong";
                    alertText = [FBErrorUtility userMessageForError:error];
                    [self showMessage:alertText withTitle:alertTitle];
                } else {

                    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                        NSLog(@"User cancelled login");
                    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                        alertTitle = @"Session Error";
                        alertText = @"Your current session is no longer valid. Please log in again.";
                        
                        [self showMessage:alertText withTitle:alertTitle];
                    } else {
                        NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                        
                        alertTitle = @"Something went wrong";
                        alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                        
                        [self showMessage:alertText withTitle:alertTitle];
                    }
                }
                
                [[FBSession activeSession] closeAndClearTokenInformation];
            }
        
            if (error && failure) {
                failure(error);
            }else if (!error && success) {
                success(session);
            }
        });
    };
}

+ (void)showMessage:(NSString *)text withTitle:(NSString *)title {
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:nil
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}
         
- (void)requestAccessToFacebookAccountsWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *facebookPermissions = @{
        ACFacebookAppIdKey: @"155721184624564",
        ACFacebookPermissionsKey: @[@"basic_info", @"publish_actions"],
        ACFacebookAudienceKey: ACFacebookAudienceEveryone
    };
    
    [accountStore requestAccessToAccountsWithType:accountType options:facebookPermissions completion:^(BOOL granted, NSError *error) {
        if (error || !granted) {
            if (error) {
                NSLog(@"An error occurred: %@", error);
            }
            [self openFacebookSessionWithLoginUI:YES success:success failure:failure];
        }else if (granted) {
            facebookAccounts = [accountStore accountsWithAccountType:accountType];
            ACAccount *facebookAccount = [facebookAccounts firstObject];
            
            [self loginWithAccount:facebookAccount success:success];
        }else {
            [self openFacebookSessionWithLoginUI:YES success:success failure:failure];
        }
    }];

}

- (void)openFacebookSessionWithLoginUI:(BOOL)loginUI success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:loginUI
                                      completionHandler:[PFacebookManager sessionCompletionHandlerWithSuccess:success failure:failure]];
    });
}

- (void)loginWithAccount:(ACAccount*)account {
    [self loginWithAccount:account success:nil];
}

- (void)loginWithAccount:(ACAccount*)account success:(PObjectResultBlock)success {
    if (![PUser currentUser].externalServices.facebook.accountIdentifier) {
        PFacebookData *facebookData = [PFacebookData facebookDataWithIdentifier:account.identifier
                                                                         userId:[[account valueForKey:@"properties"] valueForKey:@"uid"]
                                                                       username:[[account valueForKey:@"properties"] valueForKey:@"ACPropertyFullName"]];
        
        [[PUser currentUser] setFacebookData:facebookData];
    }
    
    [[self class] currentAccount];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(account);
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([FBSession activeSession].state != FBSessionStateOpen || [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
            [self openFacebookSessionWithLoginUI:YES success:^(id __unused object) {
                if ([FBSession activeSession].state == FBSessionStateOpen) {
                    // TODO: Get Facebook details on the user's profile and Mixpanel
                    NSLog(@"Fill in Mixpanel with the user's details from Facebook");
                }
            }failure:nil];
        }
    });
}

@end

@implementation PFacebookManager (Sharing)

+ (void)postObject:(id <PFBOpenGraphProtocol>)object withAction:(NSString *)action {
    NSMutableDictionary<FBOpenGraphAction> *ogAction = [FBGraphObject openGraphActionForPost];
    ogAction[object.openGraphObjectKey] = object.openGraphObject;
    
    [FBRequestConnection startForPostWithGraphPath:[NSString stringWithFormat:@"me/presenttv:%@", action]
                                       graphObject:ogAction
                                 completionHandler:self.facebookCompletionHandler];
}

+ (FBRequestHandler)facebookCompletionHandler {
    return ^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"An error occurred while requesting facebook: %@", error);
        }else {
            NSLog(@"Story successfully shared to Facebook timeline");
        }
    };
}

@end

@implementation PFacebookManager (Deprecated)
@end
