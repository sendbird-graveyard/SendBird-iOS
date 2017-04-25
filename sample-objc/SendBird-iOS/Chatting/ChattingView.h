//
//  ChattingView.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

#import "ReusableViewFromXib.h"
#import "ViewCell/MessageDelegate.h"
#import "OutgoingGeneralUrlPreviewTempModel.h"

@protocol ChattingViewDelegate <NSObject>

- (void)loadMoreMessage:(UIView *)view;
- (void)startTyping:(UIView *)view;
- (void)endTyping:(UIView *)view;
- (void)hideKeyboardWhenFastScrolling:(UIView *)view;

@end

@interface ChattingView : ReusableViewFromXib<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITableView *chattingTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputContainerViewHeight;
@property (strong, nonatomic) NSMutableArray<SBDBaseMessage *> *messages;

@property (strong, nonatomic) NSMutableDictionary<NSString *, SBDBaseMessage *> *resendableMessages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, SBDBaseMessage *> *preSendMessages;

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *resendableFileData;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *preSendFileData;

@property (weak, nonatomic) IBOutlet UIButton *fileAttachButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (atomic) BOOL stopMeasuringVelocity;
@property (atomic) BOOL initialLoading;

@property (weak, nonatomic) id<ChattingViewDelegate, MessageDelegate> delegate;

- (void)initChattingView;
- (void)scrollToBottomWithForce:(BOOL)force;
- (void)scrollToPosition:(NSInteger)position;
- (void)startTypingIndicator:(NSString *)text;
- (void)endTypingIndicator;

@end
