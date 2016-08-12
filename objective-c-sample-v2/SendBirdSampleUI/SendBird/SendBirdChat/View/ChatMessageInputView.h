//
//  ChatMessageInputView.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@protocol ChatMessageInputViewDelegate

- (void) clickSendButton:(NSString *)message;
- (void) clickFileAttachButton;
- (void) clickChannelListButton;

@end

@interface ChatMessageInputView : UIView

@property (retain) UIView *topLineView;
@property (retain) UITextField *messageTextField;
@property (retain) UIButton *sendButton;
@property (retain) UIButton *fileAttachButton;
@property (retain) UIButton *openChannelListButton;

@property (retain, nonatomic) id<ChatMessageInputViewDelegate, UITextFieldDelegate> delegate;

- (void) hideKeyboard;
- (void) setInputEnable:(BOOL)enable;
- (BOOL) isInputEnable;
- (void) hideSendButton;
- (void) showSendButton;

@end
