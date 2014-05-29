//
//  PSocialManager+Internal.h
//  Present
//
//  Created by Justin Makaila on 4/29/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

#import "PSocialManager.h"

@interface PSocialManager (Internal)

+ (void)presentViewController:(UIViewController*)viewController;
+ (void)dismissPresentedViewController;
+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message;

@end
