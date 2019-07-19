//
//  ChattingView.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <SendBirdSyncManager/SendBirdSyncManager.h>

#import "ReusableViewFromXib.h"
#import "ViewCell/MessageDelegate.h"
#import "OutgoingGeneralUrlPreviewTempModel.h"

typedef void(^ChattingViewCompletionHandler)(void);

@class SBSMMessageCollection;

@protocol ChattingViewDelegate <NSObject>

- (void)loadMoreMessage:(nonnull UIView *)view;
- (void)startTyping:(nonnull UIView *)view;
- (void)endTyping:(nonnull UIView *)view;
- (void)hideKeyboardWhenFastScrolling:(nonnull UIView *)view;

@end

@interface ChattingView : ReusableViewFromXib<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic, nonnull ,readonly) SBDBaseChannel *channel;
    
@property (weak, nonatomic, nullable) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic, nullable) IBOutlet UITableView *chattingTableView;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *inputContainerViewHeight;
@property (strong, nonatomic, nonnull) NSMutableArray<SBDBaseMessage *> *messages;

@property (strong, nonatomic, nonnull) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *resendableFileData;
@property (strong, nonatomic, nonnull) NSMutableDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> *preSendFileData;

@property (weak, nonatomic, nullable) IBOutlet UIButton *fileAttachButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *sendButton;
@property (atomic) BOOL stopMeasuringVelocity;
@property (atomic) BOOL initialLoading;

@property (weak, nonatomic, nullable) id<ChattingViewDelegate, MessageDelegate> delegate;

- (void)configureChattingViewWithChannel:(nonnull SBDBaseChannel *)channel;
- (void)scrollToBottomWithForce:(BOOL)force;
- (void)scrollToPosition:(NSInteger)position;
- (void)startTypingIndicator:(nonnull NSString *)text;
- (void)endTypingIndicator;

#pragma mark - UI for Message
- (void)insertMessages:(nonnull NSArray<SBDBaseMessage *> *)messages comparator:(nonnull SBSMObjectComparator)comparator completionHandler:(nullable SBSMVoidHandler)completionHandler;
- (void)updateMessages:(nonnull NSArray<SBDBaseMessage *> *)messages completionHandler:(nullable SBSMVoidHandler)completionHandler;
- (void)removeMessages:(nonnull NSArray<SBDBaseMessage *> *)messages completionHandler:(nullable SBSMVoidHandler)completionHandler;
- (void)clearAllMessagesWithCompletionHandler:(nullable SBSMVoidHandler)completionHandler;


@end
