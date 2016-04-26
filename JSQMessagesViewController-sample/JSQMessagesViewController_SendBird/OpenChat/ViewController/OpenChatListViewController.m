//
//  OpenChatListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "OpenChatListViewController.h"
#import "OpenChatListTableViewCell.h"
#import "OpenChatViewController.h"

@interface OpenChatListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *openChatChannelListTableView;

@property (strong, nonatomic) NSMutableArray<SendBirdChannel *> *channels;
@property (atomic) BOOL isLoading;
@property (atomic) BOOL hasNext;

@property (atomic) NSString *userID;
@property (atomic) NSString *userName;

@property (strong, nonatomic) SendBirdChannelListQuery *channelListQuery;

@end

@implementation OpenChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isLoading = NO;
    self.hasNext = YES;
    
    self.channels = [[NSMutableArray alloc] init];
    
    self.openChatChannelListTableView.delegate = self;
    self.openChatChannelListTableView.dataSource = self;
    [self.openChatChannelListTableView registerNib:[OpenChatListTableViewCell nib] forCellReuseIdentifier:[OpenChatListTableViewCell cellReuseIdentifier]];
    
    [SendBird loginWithUserId:self.userID andUserName:self.userName];
    self.channelListQuery = [SendBird queryChannelList];
    
    [self loadChannels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        
        for (SendBirdChannel *item in queryResult) {
            [self.channels addObject:item];
        }
        
        [self.openChatChannelListTableView reloadData];
        
        self.isLoading = NO;
    } endBlock:^(NSError *error) {
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
    OpenChatViewController *vc = [[OpenChatViewController alloc] init];
    [vc setTitle:[self.channels objectAtIndex:indexPath.row].name];
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
    SendBirdChannel *channel = [self.channels objectAtIndex:indexPath.row];
    OpenChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[OpenChatListTableViewCell cellReuseIdentifier]];
    [cell setModel:channel];
    
    if ([self.channels count] > 0) {
        if (indexPath.row == [self.channels count] - 1) {
            [self loadChannels];
        }
    }

    return cell;
}

@end
