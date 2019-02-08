//
//  Utils+View.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by sendbird-young on 03/02/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

#import "Utils+View.h"

@implementation Utils (View)

+ (void)tableView:(UITableView *)tableView performBatchUpdates:(void (^)(UITableView * _Nonnull))updateProcess
       completion:(void (^)(BOOL))completionHandler {
    if (@available(iOS 11.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [tableView performBatchUpdates:^{
                    updateProcess(tableView);
                } completion:completionHandler];
            } @catch (NSException *exception) {
                NSLog(@"Error updating table view: %@", exception);
                if (completionHandler != nil) {
                    completionHandler(NO);
                }
            }
        });
    } else {
        // Fallback on earlier versions
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [tableView beginUpdates];
                updateProcess(tableView);
                [tableView endUpdates];
                if (completionHandler != nil) {
                    completionHandler(YES);
                }
            } @catch (NSException *exception) {
                if (completionHandler != nil) {
                    completionHandler(NO);
                }
            }
        });
    }
}

+ (BOOL)isTopViewController:(UIViewController *)viewController {
    return (viewController == [self topViewController]);
}

+ (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    if (presentedViewController.isBeingDismissed) {
        return rootViewController;
    }
    
    if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)presentedViewController;
        UIViewController *lastViewController = navigationController.viewControllers.lastObject;
        return [self topViewController:lastViewController];
    }
    
    return [self topViewController:presentedViewController];
}


@end
