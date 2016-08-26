//
//  OpenChatViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "JSQMessages.h"
#import "JSQSBMessage.h"

@protocol OpenChannelViewControllerDelegate <NSObject>

- (void)didCloseOpenChannelViewController:(UIViewController * _Nonnull)vc;

@end

@interface OpenChannelViewController : JSQMessagesViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBDConnectionDelegate, SBDChannelDelegate>

@property (strong, atomic, nonnull) SBDOpenChannel *channel;
@property (nullable, nonatomic, weak) id<OpenChannelViewControllerDelegate> delegate;

@end
