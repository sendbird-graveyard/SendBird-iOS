//
//  MessageDelegate.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@protocol MessageDelegate <NSObject>

- (void)clickProfileImage:(UITableViewCell *)viewCell user:(SBDUser *)user;
- (void)clickMessage:(UIView *)view message:(SBDBaseMessage *)message;
- (void)clickResend:(UIView *)view message:(SBDBaseMessage *)message;
- (void)clickDelete:(UIView *)view message:(SBDBaseMessage *)message;

@end
