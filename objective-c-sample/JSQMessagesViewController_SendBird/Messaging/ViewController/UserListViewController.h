//
//  MemberListViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@class UserListViewController;

@protocol UserListViewControllerDelegate <NSObject>

- (void)didCloseUserListViewController:(UserListViewController * _Nonnull)vc groupChannel:(SBDGroupChannel * _Nullable)groupChannel;

@end

@interface UserListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nullable, nonatomic, weak) id<UserListViewControllerDelegate> delegate;

@property (atomic) int invitationMode; // 0: Start new channel, 1: Invite other to the current channel.
@property (strong, nonatomic, nullable) SBDGroupChannel *currentChannel;

@end
