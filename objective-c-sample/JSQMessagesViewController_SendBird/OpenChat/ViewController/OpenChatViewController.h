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

@interface OpenChatViewController : JSQMessagesViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBDConnectionDelegate, SBDChannelDelegate>

@property (strong, atomic) SBDOpenChannel *channel;

@end
