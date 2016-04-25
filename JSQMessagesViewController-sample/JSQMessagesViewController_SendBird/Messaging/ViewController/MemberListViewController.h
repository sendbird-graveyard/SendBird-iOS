//
//  MemberListViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface MemberListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (void)setUserID:(NSString *)aUserID userName:(NSString *)aUserName;

@end
