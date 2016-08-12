//
//  ChannelListTableView.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"
#import "ChattingTableViewController.h"
#import "ChannelTableViewCell.h"

@class ChattingTableViewController;
@interface ChannelListTableView : UIView

@property (retain) UIView *searchAreaView;
@property (retain) UITextField *searchTextField;
@property (retain) UITableView *channelTableView;
@property (nonatomic, retain) NSMutableArray *channels;
@property (nonatomic, retain) NSMutableArray *messagingChannels;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (retain) id<UITableViewDataSource, UITableViewDelegate> delegate;
@property (retain) ChattingTableViewController *chattingTableViewController;

- (void)viewDidLoad;
- (void) loadChannels;
- (void) reloadChannels;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
