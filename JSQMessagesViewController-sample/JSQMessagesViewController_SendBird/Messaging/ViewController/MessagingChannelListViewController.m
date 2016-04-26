//
//  MessagingChannelListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MessagingChannelListViewController.h"
#import "MessagingChannelListTableViewCell.h"
#import "MessagingViewController.h"

@interface MessagingChannelListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *messagingChannelListTableView;

@property (strong, nonatomic) NSMutableArray<SendBirdMessagingChannel *> *channels;
@property (atomic) BOOL isLoading;
@property (atomic) BOOL hasNext;

@property (atomic) NSString *userID;
@property (atomic) NSString *userName;

@property (strong, nonatomic) SendBirdMessagingChannelListQuery *channelListQuery;

@end

@implementation MessagingChannelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.isLoading = NO;
    self.hasNext = YES;
    
    self.title = @"Messaging Channel List";
    
    self.channels = [[NSMutableArray alloc] init];
    
    self.messagingChannelListTableView.delegate = self;
    self.messagingChannelListTableView.dataSource = self;
    [self.messagingChannelListTableView registerNib:[MessagingChannelListTableViewCell nib] forCellReuseIdentifier:[MessagingChannelListTableViewCell cellReuseIdentifier]];
    
    [SendBird loginWithUserId:self.userID andUserName:self.userName];
    self.channelListQuery = [SendBird queryMessagingChannelList];
    
    [self loadChannels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadChannels {
    if (self.isLoading) {
        return;
    }
    
    if (!self.hasNext) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.channelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        if ([queryResult count] > 0) {
            self.hasNext = YES;
        }
        else {
            self.hasNext = NO;
        }
        
        for (SendBirdMessagingChannel *item in queryResult) {
            [self.channels addObject:item];
        }
        
        [self.messagingChannelListTableView reloadData];
        
        self.isLoading = NO;
    } endBlock:^(NSInteger code) {
        self.isLoading = NO;
    }];
}

- (void)setUserID:(NSString *)aUserID userName:(NSString *)aUserName {
    self.userID = aUserID;
    self.userName = aUserName;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MessagingViewController *vc = [[MessagingViewController alloc] init];
    [vc setTitle:@"Messaging"];
    [vc setSenderId:[SendBird getUserId]];
    [vc setSenderDisplayName:[SendBird getUserName]];
    [vc setChannel:[self.channels objectAtIndex:indexPath.row]];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SendBirdMessagingChannel *channel = [self.channels objectAtIndex:indexPath.row];
    MessagingChannelListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MessagingChannelListTableViewCell cellReuseIdentifier]];
    [cell setModel:channel];
    
    if ([self.channels count] > 0) {
        if (indexPath.row == [self.channels count] - 1) {
            [self loadChannels];
        }
    }
    
    return cell;
}

@end
