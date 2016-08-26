//
//  GroupChannelListViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "GroupChannelViewController.h"
#import "UserListViewController.h"

@interface GroupChannelListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SBDConnectionDelegate, SBDChannelDelegate, GroupChannelViewControllerDelegate, UserListViewControllerDelegate>

- (void)setUserID:(NSString *)aUserID userName:(NSString *)aUserName;

@end
