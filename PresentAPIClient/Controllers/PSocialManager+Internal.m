//
//  PSocialManager+Internal.m
//  Present
//
//  Created by Justin Makaila on 4/29/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PSocialManager+Internal.h"

@implementation PSocialManager (Internal)

+ (UIViewController*)rootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
}

+ (void)presentViewController:(UIViewController *)viewController {
    [self.rootViewController presentViewController:viewController animated:YES completion:nil];
}

+ (void)dismissPresentedViewController {
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

@end
