//
//  Application.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by sendbird-young on 2018. 4. 13..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import "Application.h"
#import <UIKit/UIKit.h>

@implementation Application

+ (BOOL)canOpenURL:(NSURL *)url {
    if (url == nil) {
        return NO;
    }
    
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (void)openURL:(NSURL *)url {
    [self openURL:url options:nil completionHandler:nil];
}

+ (void)openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options completionHandler:(void (^)(BOOL))completionHandler {
    if (url == nil) {
        if (completionHandler != nil) {
            completionHandler(NO);
        }
        return;
    }
    
    if (options == nil) {
        options = [NSDictionary dictionary];
    }
    
    // open url along os version
    if ([self canOpenURL:url]) {
        float osVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (osVersion >= 10.0) {
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0)
            [[UIApplication sharedApplication] openURL:url
                                               options:options
                                     completionHandler:completionHandler];
#endif
            return;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
            if (completionHandler != nil) {
                completionHandler(YES);
            }
        }
    }
    else {
        if (completionHandler != nil) {
            completionHandler(NO);
        }
    }
}

@end
