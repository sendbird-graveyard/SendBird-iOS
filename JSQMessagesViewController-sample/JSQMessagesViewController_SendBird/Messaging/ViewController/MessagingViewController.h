//
//  MessagingViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "JSQMessages.h"
#import "JSQSBMessage.h"

#define MESSAGING_START_WITH_USERIDS 0
#define MESSAGING_START_WITH_CHANNELURL 1

@interface MessagingViewController : JSQMessagesViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)inviteUsers:(NSArray *)aUserIds;
- (void)joinMessagingChannel:(NSString *)aChannelUrl;
- (void)setChannel:(SendBirdMessagingChannel *)aMessagingChannel;

@end
