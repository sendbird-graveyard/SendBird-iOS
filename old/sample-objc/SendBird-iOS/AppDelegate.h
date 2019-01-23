//
//  AppDelegate.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, nullable) UIWindow *window;

@property (strong, nonatomic, nullable) NSString *receivedPushChannelUrl;

+ (nonnull NSURLCache *)imageCache;

@end

