//
//  MemberListViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 8/11/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface MemberListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic, nullable) SBDGroupChannel *currentChannel;

@end
