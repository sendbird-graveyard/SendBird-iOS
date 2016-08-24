//
//  MessagingChannelListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MessagingChannelListViewController.h"
#import "MessagingChannelListTableViewCell.h"
#import "MessagingViewController.h"

@interface MessagingChannelListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *messagingChannelListTableView;
@property (strong, nonatomic) NSMutableArray<SBDGroupChannel *> *channels;
@property (atomic) NSString *userID;
@property (atomic) NSString *userName;
@property (strong, nonatomic) SBDGroupChannelListQuery *myGroupChannelListQuery;
@property (strong, nonatomic, nonnull) NSString *delegateIndetifier;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (atomic) BOOL editMode;
@property (strong, nonatomic, nonnull) UIBarButtonItem *editChannelListButtomItem;
@property (strong, nonatomic, nonnull) UIBarButtonItem *doneChannelListButtomItem;
@property (strong, nonatomic, nonnull) UIBarButtonItem *createChannelButtomItem;

@end

@implementation MessagingChannelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"Group Channel List";
    self.editMode = NO;
    
    self.channels = [[NSMutableArray alloc] init];
    
    self.messagingChannelListTableView.delegate = self;
    self.messagingChannelListTableView.dataSource = self;
    [self.messagingChannelListTableView registerNib:[MessagingChannelListTableViewCell nib] forCellReuseIdentifier:[MessagingChannelListTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannelList) forControlEvents:UIControlEventValueChanged];
    [self.messagingChannelListTableView addSubview:self.refreshControl];
    
    self.myGroupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
    self.myGroupChannelListQuery.limit = 10;
    
    self.delegateIndetifier = self.description;
    
    self.editChannelListButtomItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editGroupChannelList)];
    self.doneChannelListButtomItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editGroupChannelList)];
    self.createChannelButtomItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createGroupChannel)];
    
    self.navigationItem.rightBarButtonItems = @[self.createChannelButtomItem,
                                                self.editChannelListButtomItem];
    
    [SBDMain addChannelDelegate:self identifier:self.delegateIndetifier];
    [SBDMain addConnectionDelegate:self identifier:self.delegateIndetifier];
    
    [self loadChannels];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [SBDMain removeChannelDelegateForIdentifier:self.delegateIndetifier];
        [SBDMain removeConnectionDelegateForIdentifier:self.delegateIndetifier];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createGroupChannel {
    UserListViewController *vc = [[UserListViewController alloc] init];
    vc.invitationMode = 0;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editGroupChannelList {
    if (self.editMode) {
        self.title = @"Group Channels";
        self.editMode = NO;
        self.createChannelButtomItem.enabled = YES;
        self.navigationItem.rightBarButtonItems = @[self.createChannelButtomItem,
                                                    self.editChannelListButtomItem];
    }
    else {
        self.title = @"Edit Group Channels";
        self.editMode = YES;
        self.createChannelButtomItem.enabled = NO;
        self.navigationItem.rightBarButtonItems = @[self.createChannelButtomItem,
                                                    self.doneChannelListButtomItem];
    }
}

- (void)refreshChannelList {
    if (self.myGroupChannelListQuery != nil && self.myGroupChannelListQuery.isLoading) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.channels removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messagingChannelListTableView reloadData];
    });
    self.myGroupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
    self.myGroupChannelListQuery.limit = 10;
    [self loadChannels];
}

- (void)loadChannels {
    if (self.myGroupChannelListQuery.isLoading) {
        return;
    }
    
    if (!self.myGroupChannelListQuery.hasNext) {
        return;
    }

    [self.myGroupChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            return;
        }
        
        if (channels == nil || channels.count == 0) {            
            return;
        }
        
        for (SBDGroupChannel *channel in channels) {
            [self.channels addObject:channel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagingChannelListTableView reloadData];
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
        });
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
    __block SBDGroupChannel *channel = [self.channels objectAtIndex:indexPath.row];
    
    if (self.editMode) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *leaveChannelAction =  [UIAlertAction actionWithTitle:@"Leave channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.channels removeObject:channel];
                    [self.messagingChannelListTableView reloadData];
                });
            }];
        }];
        UIAlertAction *hideChannelAction = [UIAlertAction actionWithTitle:@"Hide channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [channel hideChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.channels removeObject:channel];
                    [self.messagingChannelListTableView reloadData];
                });
            }];
        }];;
        
        [alert addAction:closeAction];
        [alert addAction:leaveChannelAction];
        [alert addAction:hideChannelAction];
    
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        MessagingViewController *vc = [[MessagingViewController alloc] init];
        [vc setTitle:@"Messaging"];
        [vc setSenderId:[SBDMain getCurrentUser].userId];
        [vc setSenderDisplayName:[SBDMain getCurrentUser].nickname];
        [vc setChannel:[self.channels objectAtIndex:indexPath.row]];
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDGroupChannel *channel = [self.channels objectAtIndex:indexPath.row];
    MessagingChannelListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MessagingChannelListTableViewCell cellReuseIdentifier]];
    [cell setModel:channel];
    
    if ([self.channels count] > 0) {
        if (indexPath.row == [self.channels count] - 1) {
            [self loadChannels];
        }
    }
    
    return cell;
}

#pragma mark - SBDConnectionDelegate
- (void)didStartReconnection {
    NSLog(@"didStartReconnection in MessagingChannelListViewController");
}

- (void)didSucceedReconnection {
    NSLog(@"didSucceedReconnection in MessagingChannelListViewController");
}

- (void)didFailReconnection {
    NSLog(@"didFailReconnection in MessagingChannelListViewController");
}

#pragma mark - SBDChannelDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    NSLog(@"channel:didReceiveMessage: in MessagingChannelListViewController");
    
    if ([sender isKindOfClass:[SBDGroupChannel class]]) {
        BOOL isNewChannel = YES;
        ((SBDGroupChannel *)sender).lastMessage = message;
        for (SBDBaseChannel *channelInList in self.channels) {
            if ([sender.channelUrl isEqualToString:channelInList.channelUrl]) {
                isNewChannel = NO;
            }
        }
        
        if (isNewChannel == NO) {
            [self.channels removeObject:(SBDGroupChannel *)sender];
        }
        
        [self.channels insertObject:(SBDGroupChannel *)sender atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagingChannelListTableView reloadData];
        });
    }
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    NSLog(@"channelDidUpdateReadReceipt: in MessagingChannelListViewController");
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    NSLog(@"channelDidUpdateTypingStatus: in MessagingChannelListViewController");
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidJoin: in MessagingChannelListViewController");
    BOOL isNewChannel = YES;
    for (SBDGroupChannel *channel in self.channels) {
        if (sender == channel) {
            isNewChannel = NO;
            break;
        }
    }
    
    if (isNewChannel == YES) {
        [self.channels insertObject:sender atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagingChannelListTableView reloadData];
        });
    }
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidLeave: in MessagingChannelListViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidEnter: in MessagingChannelListViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidExit:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidExit: in MessagingChannelListViewController");
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    NSLog(@"channelWasDeleted:channelUrl: in MessagingChannelListViewController");
}

- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    NSLog(@"channelWasChanged: in MessagingChannelListViewController");
    BOOL channelExist = NO;
    for (SBDGroupChannel *channel in self.channels) {
        if (sender == channel) {
            channelExist = YES;
            break;
        }
    }
    
    if (channelExist == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagingChannelListTableView reloadData];
        });
    }
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    NSLog(@"channel:messageWasDeleted: in MessagingChannelListViewController");
}

#pragma mark - MessagingViewControllerDelegate
- (void)didCloseMessagingViewController:(MessagingViewController * _Nonnull)vc {
    NSLog(@"didCloseMessagingViewController: in MessagingChannelListViewController");
    
    [self refreshChannelList];
//    [self.channels removeAllObjects];
//    [self.messagingChannelListTableView reloadData];
//
//    self.myGroupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
//    self.myGroupChannelListQuery.limit = 10;
//    [self loadChannels];
}

#pragma mark - UserListViewControllerDelegate
- (void)didCloseUserListViewController:(UserListViewController * _Nonnull)vc groupChannel:(SBDGroupChannel * _Nullable)groupChannel {
    NSLog(@"didCloseMessagingViewController: in MessagingChannelListViewController");
    [self refreshChannelList];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
        if (groupChannel != nil) {
            MessagingViewController *vc = [[MessagingViewController alloc] init];
            [vc setTitle:@"Messaging"];
            [vc setSenderId:[SBDMain getCurrentUser].userId];
            [vc setSenderDisplayName:[SBDMain getCurrentUser].nickname];
            [vc setChannel:groupChannel];
            vc.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:vc animated:NO];
            });
        }
    });
}

@end
