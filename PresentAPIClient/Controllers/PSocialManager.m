//
//  PSocialManager.m
//  Present
//
//  Created by Justin Makaila on 4/17/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PSocialManager.h"
#import "PSocialManager+Internal.h"

#import <Social/Social.h>

#import "PFacebookManager.h"
#import "PTwitterManager.h"

#import "PVideo.h"
#import "PUser.h"

#define kTwitterConsumerKey      @"1OQL9wYfSydCUzm9E7kjJA"
#define kTwitterConsumerSecret   @"hUQ31sKZBh1zz4ZJLjV2d8WuGILP6iT0wP2RyVSZ04s"

@implementation PSocialManager

+ (PSocialManager*)sharedManager {
    static PSocialManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PSocialManager alloc] init];
        sharedManager.facebookManager = [PFacebookManager sharedManager];
        sharedManager.twitterManager = [PTwitterManager sharedManager];
    });
    
    return sharedManager;
}

+ (void)initialize {
    [self sharedManager];
    [PFacebookManager initializeFacebook];
    [PTwitterManager initializeWithConsumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
    
    [super initialize];
}

+ (void)start {
    [PFacebookManager start];
    [PTwitterManager start];
}

+ (BOOL)currentUserIsLinkedWithAccount:(PSocialAccountTypeIdentifier)accountIdentifier {
    switch (accountIdentifier) {
        case PSocialAccountTypeIdentifierFacebook:
            return [PFacebookManager isLinkedWithUser:[PUser currentUser]];
            break;
        case PSocialAccountTypeIdentifierTwitter:
            return [PTwitterManager isLinkedWithUser:[PUser currentUser]];
            break;
        default:
            break;
    }
}

+ (void)linkCurrentUserToAccountType:(PSocialAccountTypeIdentifier)accountIdentifier success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    switch (accountIdentifier) {
        case PSocialAccountTypeIdentifierFacebook:
            [PFacebookManager linkUser:[PUser currentUser] success:success failure:failure];
            break;
        case PSocialAccountTypeIdentifierTwitter:
            [PTwitterManager linkUser:[PUser currentUser] success:success failure:failure];
            break;
        default:
            break;
    }
}

+ (void)requestAccessToAccountType:(PSocialAccountTypeIdentifier)accountIdentifier success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    switch (accountIdentifier) {
        case PSocialAccountTypeIdentifierFacebook:
            [[self sharedManager].facebookManager requestAccessToFacebookAccountsWithSuccess:success failure:failure];
            break;
        case PSocialAccountTypeIdentifierTwitter:
            [[self sharedManager].twitterManager requestAccessToTwitterAccountsWithSuccess:success failure:failure];
            break;
        default:
            break;
    }
}

+ (void)showComposeControllerForAccountType:(PSocialAccountTypeIdentifier)accountIdentifier withMessage:(NSString*)message url:(NSURL*)url success:(PObjectResultBlock)success failure:(PFailureBlock)failure {
    NSString *serviceType = nil;
    switch (accountIdentifier) {
        case PSocialAccountTypeIdentifierFacebook:
            serviceType = SLServiceTypeFacebook;
            break;
        case PSocialAccountTypeIdentifierTwitter:
            serviceType = SLServiceTypeTwitter;
            break;
        default:
            break;
    }
    
    if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeViewController setInitialText:message];
        [composeViewController addURL:url];
        
        composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    if (failure) {
                        NSError *error = [NSError errorWithDomain:PSocialManagerErrorDomain code:1000 userInfo:@{
                            NSLocalizedDescriptionKey: @"User cancelled post"
                        }];
                        
                        failure(error);
                    }
                    break;
                case SLComposeViewControllerResultDone:
                    if (success) {
                        success(nil);
                    }
                    break;
                default:
                    break;
            }
        };
        
        [self presentViewController:composeViewController];
    }else {
        if (failure) {
            NSError *error = [NSError errorWithDomain:PSocialManagerErrorDomain code:1001 userInfo:@{
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No linked %@ account", (accountIdentifier == PSocialAccountTypeIdentifierFacebook) ? @"Facebook" : @"Twitter"]
            }];
            
            failure(error);
        }
    }
}

@end

@implementation PSocialManager (PFacebookManager)

+ (void)postObjectToFacebook:(PObject<PFBOpenGraphProtocol> *)object withAction:(PFacebookShareAction)action {
    if (action == PFacebookShareActionVideoLike || action == PFacebookShareActionVideoPost) {
        if (![object isKindOfClass:[PVideo class]]) {
            return;
        }
    }else if (action == PFacebookShareActionUserDemand || action == PFacebookShareActionUserJoin) {
        if (![object isKindOfClass:[PUser class]]) {
            return;
        }
    }
    
    NSString *shareAction;
    switch (action) {
        case PFacebookShareActionShare:
            shareAction = @"share";
            break;
        case PFacebookShareActionVideoLike:{
            shareAction = @"liked";
            break;
        }case PFacebookShareActionVideoPost:{
            shareAction = @"post";
            break;
        }case PFacebookShareActionUserDemand:{
            shareAction = @"demand";
            break;
        }case PFacebookShareActionUserJoin:{
            shareAction = @"joined";
            break;
        }
        default:
            break;
    }
    
    if (!shareAction) {
        return;
    }
    
    [PFacebookManager postObject:object withAction:shareAction];
}

@end

@implementation PSocialManager (PTwitterManager)

+ (void)postObjectToTwitter:(PObject<PTwitterShareProtocol> *)object withAction:(PTwitterShareAction)action {
    NSString *tweetBody;
    switch (action) {
        case PTwitterShareActionShare:
            tweetBody = object.twitterShareString;
            break;
        case PTwitterShareActionPost:
            tweetBody = object.twitterPostString;
            break;
        default:
            break;
    }
    
    [PTwitterManager postTweetWithMessage:tweetBody];
}

@end

@implementation PSocialManager (SMS)

+ (void)showMFMessageComposeViewControllerForObject:(id<PSMSShareProtocol>)object {
    [self showMFMessageComposeViewControllerWithText:object.textMessageBody];
}

+ (void)showMFMessageComposeViewControllerWithText:(NSString *)text {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        [messageController setMessageComposeDelegate:self.sharedManager];
        [messageController setBody:text];
        
        [self presentViewController:messageController];
    }
}

#pragma mark - MFMessageComposeViewController Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            [PSocialManager showAlertViewWithTitle:@"Error" message:@"Could not send SMS. Please try again."];
            break;
        default:
            break;
    }
    
    [PSocialManager dismissPresentedViewController];
}

@end

@implementation PSocialManager (Email)

+ (void)showMFMailComposeViewControllerForObject:(id<PEmailShareProtocol>)object {
    [self showMFMailComposeViewControllerWithSubjectLine:object.emailSubject messageBody:object.emailBody recipients:nil];
}

+ (void)showMFMailComposeViewControllerWithSubjectLine:(NSString*)subject messageBody:(NSString*)messageBody recipients:(NSArray*)recipients {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self.sharedManager];
        [mailController setSubject:subject];
        [mailController setToRecipients:recipients];
        [mailController setMessageBody:messageBody isHTML:NO];
        
        [self presentViewController:mailController];
    }else {
        [PSocialManager showAlertViewWithTitle:@"No Mail Accounts" message:@"Please set up a Mail account in the Settings app."];
    }
}

#pragma mark - MFMailComposeViewController delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [PSocialManager dismissPresentedViewController];
}

@end
