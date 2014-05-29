//
//  PTwitterManager.m
//  Present
//
//  Created by Justin Makaila on 3/6/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PTwitterManager.h"

#import <Social/Social.h>

#import <STTwitter.h>

#import "PUserContext.h"
#import "PUser.h"
#import "PExternalServices.h"
#import "PSocialData.h"

@interface PTwitterManager () <UIActionSheetDelegate> {
    NSArray *twitterAccounts;
    
    NSString *consumerKey;
    NSString *consumerSecretKey;
}

@property (copy, nonatomic) PObjectResultBlock linkSuccessBlock;
@property (copy, nonatomic) PObjectResultBlock actionSheetBlock;

- (void)oAuthCallback;

@end

static ACAccount *_currentAccount;

@implementation PTwitterManager

+ (PTwitterManager*)sharedManager {
    static PTwitterManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PTwitterManager alloc] init];
    });
    
    return manager;
}

+ (ACAccount*)currentAccount {
    if (!_currentAccount) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        PTwitterData *twitterData = [PUser currentUser].externalServices.twitter;
        if (twitterData.accountIdentifier) {
            _currentAccount = [accountStore accountWithIdentifier:twitterData.accountIdentifier];
        }
    }
    
    return _currentAccount;
}

+ (void)start {
    if ([self currentAccount]) {
        [[self sharedManager] loginWithAccount:_currentAccount];
    }
}

+ (void)initializeWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret {
    PTwitterManager *manager = [self sharedManager];
    manager->consumerKey = consumerKey;
    manager->consumerSecretKey = consumerSecret;
}

+ (void)setOAuthToken:(NSString*)token oAuthVerifier:(NSString*)verifier {
     PTwitterManager *manager = [self sharedManager];
    
    [manager.twitterAPI postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userId, NSString *screenName) {
        PTwitterData *twitterData = [PUser currentUser].externalServices.twitter;
        twitterData.username = screenName;
        twitterData.userId = userId;
        
        [manager addAccountWithOAuthToken:oAuthToken oAuthSecret:oAuthTokenSecret];
        [manager oAuthCallback];
    }errorBlock:^(NSError *error) {
        NSLog(@"An error occurred");
    }];
}

+ (BOOL)isLinkedWithUser:(PUser *)user {
    return !![self currentAccount];
}

+ (void)linkUser:(PUser *)user success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    [[PTwitterManager sharedManager] requestAccessToTwitterAccountsWithSuccess:success failure:failure];
}

+ (void)unlinkUser:(PUser *)user success:(PObjectResultBlock)success error:(PFailureBlock)failure {
    [PUser currentUser].externalServices.twitter = nil;
    _currentAccount = nil;
    
    [[PUserContext currentContext] saveToDisk];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(nil);
        });
    }
}

+ (void)postTweetWithMessage:(NSString *)message {
    [[PTwitterManager sharedManager].twitterAPI postStatusUpdate:message
                                               inReplyToStatusID:nil
                                                        latitude:nil
                                                       longitude:nil
                                                         placeID:nil
                                              displayCoordinates:nil
                                                        trimUser:@0
                                                    successBlock:self.twitterSuccessBlock
                                                      errorBlock:self.twitterErrorBlock];
}

+ (PObjectResultBlock)twitterSuccessBlock {
    return ^(NSDictionary *responseDictionary) {
        NSLog(@"Successfully posted to twitter!");
    };
}

+ (PFailureBlock)twitterErrorBlock {
    return ^(NSError *error) {
        NSLog(@"An error occurrred while requesting Twitter:\n%@", error);
    };
}

- (void)requestAccessToTwitterAccountsWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (error) {
            [self loginWithSafariWithSuccess:success failure:failure];
        }else {
            twitterAccounts = [accountStore accountsWithAccountType:accountType];
            if (twitterAccounts.count > 0) {
                if ([PUser currentUser].twitterHandle) {
                    for (ACAccount *account in twitterAccounts) {
                        if ([account.username isEqualToString:[PUser currentUser].twitterHandle]) {
                            return [self loginWithAccount:account success:success];
                        }
                    }
                }
                
                self.actionSheetBlock = success;
                [self showAlertViewForAccounts];
            }else {
                [self loginWithSafariWithSuccess:success failure:failure];
            }
        }
    }];
}

- (void)addAccountWithOAuthToken:(NSString *)oAuthToken oAuthSecret:(NSString *)oAuthSecret {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountCredential *credential = [[ACAccountCredential alloc] initWithOAuthToken:oAuthToken tokenSecret:oAuthSecret];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccount *twitterAccount = [[ACAccount alloc] initWithAccountType:twitterAccountType];
    twitterAccount.credential = credential;
    
    [accountStore saveAccount:twitterAccount withCompletionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [self loginWithAccount:twitterAccount];
        }else {
            NSLog(@"An error occurred while saving the user's Twitter account: %@", error);
        }
    }];
}

- (void)loginWithAccount:(ACAccount*)account {
    [self loginWithAccount:account success:nil];
}

- (void)loginWithAccount:(ACAccount*)account success:(PObjectResultBlock)success {
    self.twitterAPI = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    if (![PUser currentUser].externalServices.twitter.accountIdentifier) {
        PTwitterData *twitterData = [PTwitterData twitterDataWithIdentifier:account.identifier
                                                                     userId:[[account valueForKey:@"properties"] valueForKey:@"user_id"]
                                                                   username:account.username];
        
        [[PUser currentUser] setTwitterData:twitterData];
    }
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(account); 
        });
    }
}

- (void)loginWithSafariWithSuccess:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    self.linkSuccessBlock = success;
    
    void (^requestBlock)(NSURL *, NSString *) = ^(NSURL *url, NSString *oauthToken) {
        [[UIApplication sharedApplication] openURL:url];
    };
    
    if (!self.twitterAPI) {
        self.twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerKey consumerSecret:consumerSecretKey];
    }
    
    [self.twitterAPI postTokenRequest:requestBlock
                              forceLogin:@(YES)
                              screenName:nil
                           oauthCallback:@"twitter4213836://oauth_callback"
                              errorBlock:^(NSError *error) {
                                  if (failure) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          failure(error);
                                      });
                                  }
                              }];
}

- (void)showAlertViewForAccounts {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a default account:"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    // TODO: Associate the twitterAccounts array with the UIActionSheet
    for (ACAccount *account in twitterAccounts) {
        [actionSheet addButtonWithTitle:[account.username copy]];
    }
    
    [actionSheet addButtonWithTitle:@"Other"];
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.destructiveButtonIndex = actionSheet.cancelButtonIndex;
    
    UINavigationController *navigationController = ((UINavigationController*)[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentedViewController]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [actionSheet showInView:navigationController.topViewController.view];
    });
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    /**
     *  NSArray *twitterAccounts = (NSArray*)[actionSheet associatedObject];
     *  ACAccount *account = twitterAccounts[buttonIndex];
     */
    
    if (buttonIndex < actionSheet.numberOfButtons - 2) {
        ACAccount *account = twitterAccounts[buttonIndex];
        [self loginWithAccount:account];
        [self actionSheetCallback:account];
    }else if (buttonIndex == actionSheet.numberOfButtons - 2) {
        [self loginWithSafariWithSuccess:self.actionSheetBlock failure:nil];
    }
}

- (void)oAuthCallback {
    if (self.linkSuccessBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.linkSuccessBlock(nil);
            self.linkSuccessBlock = nil;
        });
    }
}

- (void)actionSheetCallback:(ACAccount*)account {
    if (self.actionSheetBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.actionSheetBlock(account);
            self.actionSheetBlock = nil;
        });
    }
}

@end
