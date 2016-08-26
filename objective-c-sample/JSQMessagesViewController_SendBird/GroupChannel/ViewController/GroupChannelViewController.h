//
//  MessagingViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "JSQMessages.h"
#import "JSQSBMessage.h"

#import "UserListViewController.h"

#define MESSAGING_START_WITH_USERIDS 0
#define MESSAGING_START_WITH_CHANNELURL 1

@class GroupChannelViewController;

@protocol GroupChannelViewControllerDelegate <NSObject>

- (void)didCloseMessagingViewController:(GroupChannelViewController * _Nonnull)vc;

@end

@interface GroupChannelViewController : JSQMessagesViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, SBDConnectionDelegate, SBDChannelDelegate, UserListViewControllerDelegate>

@property (nullable,nonatomic,weak) id<GroupChannelViewControllerDelegate> delegate;

- (void)inviteUsers:(NSArray * _Nullable)aUserIds;
- (void)joinMessagingChannel:(NSString * _Nullable)aChannelUrl;
- (void)setChannel:(SBDGroupChannel * _Nullable)aGroupChannel;

@end
