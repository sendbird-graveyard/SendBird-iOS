//
//  AppDelegate.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 12/30/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property NSOperationQueue *taskQueue;
@property (strong, nonatomic) ViewController *viewController;

@end

