//
//  JSQSBMessage.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "JSQMessage.h"

@interface JSQSBMessage : JSQMessage

@property (strong, nonnull) SBDBaseMessage *message;

@end
