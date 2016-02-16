//
//  ChattingTableViewController.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"
#import "IndicatorView.h"
#import "ChatMessageInputView.h"
#import "ChannelListTableView.h"
#import "FileLinkTableViewCell.h"
#import "FileMessageTableViewCell.h"
#import "BroadcastMessageTableViewCell.h"
#import "MessageTableViewCell.h"
#import "SystemMessageTableViewCell.h"
#import "StructuredMessageTableViewCell.h"

@class IndicatorView;
@class ChannelListTableView;
@interface ChattingTableViewController : UIViewController

@property (retain) UIView *container;
@property (retain) UITableView *tableView;
@property (retain) ChatMessageInputView *messageInputView;
@property (retain) NSString *channelUrl;
@property BOOL openImagePicker;
@property (retain) IndicatorView *indicatorView;
@property (retain) ChannelListTableView *channelListTableView;
//@property (retain) UIView *customTitleView;
@property (retain) UILabel *titleLabel;
//@property (retain) UIImageView *caret;
@property (retain) NSString *userId;
@property (retain) NSString *userName;

- (id) init;
- (void) setViewMode:(int)mode;
- (void) startChatting;
- (void)setIndicatorHidden:(BOOL)hidden;
- (void) initChannelTitle;
- (void) updateChannelTitle;

@end
