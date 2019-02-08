//
//  GroupChannelChattingViewController.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/27/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "ChattingView.h"
#import "../Chatting/ViewCell/MessageDelegate.h"

@interface GroupChannelChattingViewController : UIViewController<ChattingViewDelegate, MessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) SBDGroupChannel *channel;

@end
