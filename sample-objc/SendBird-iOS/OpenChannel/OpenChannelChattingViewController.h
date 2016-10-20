//
//  OpenChannelChattingViewController.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "ChattingView.h"
#import "../Chatting/ViewCell/MessageDelegate.h"

@interface OpenChannelChattingViewController : UIViewController<SBDConnectionDelegate, SBDChannelDelegate, ChattingViewDelegate, MessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) SBDOpenChannel *channel;

@end
