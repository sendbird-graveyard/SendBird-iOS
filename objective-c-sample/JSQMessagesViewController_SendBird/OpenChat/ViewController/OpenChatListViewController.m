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

@interface OpenChatListViewController ()<SBDConnectionDelegate, SBDChannelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *openChatChannelListTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

@property (strong, nonatomic) NSMutableArray<SBDOpenChannel *> *channels;
@property (atomic) BOOL isLoading;
@property (atomic) BOOL hasNext;

@property (atomic) NSString *userID;
@property (atomic) NSString *userName;

@property (strong, nonatomic) SBDOpenChannelListQuery *channelListQuery;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation OpenChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Open Channels";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createOpenChannel)];
    
    self.isLoading = NO;
    self.hasNext = YES;
    self.loadingActivityIndicator.hidesWhenStopped = YES;
    [self.loadingActivityIndicator stopAnimating];
    
    self.channels = [[NSMutableArray alloc] init];
    
    self.openChatChannelListTableView.delegate = self;
    self.openChatChannelListTableView.dataSource = self;
    [self.openChatChannelListTableView registerNib:[OpenChatListTableViewCell nib] forCellReuseIdentifier:[OpenChatListTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannelList) forControlEvents:UIControlEventValueChanged];
    [self.openChatChannelListTableView addSubview:self.refreshControl];

    self.channelListQuery = [SBDOpenChannel createOpenChannelListQuery];
    
    [self loadChannels];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createOpenChannel {
    NSLog(@"createOpenChannel");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create Open Channel" message:@"Create open channel with name." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameTextField = alert.textFields[0];
        
        if (nameTextField.text.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingActivityIndicator setHidden:NO];
                [self.loadingActivityIndicator startAnimating];
            });

            [SBDOpenChannel createChannelWithName:nameTextField.text coverUrl:nil data:nil operatorUsers:@[[SBDMain getCurrentUser]] completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingActivityIndicator stopAnimating];
                    });
                    
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.channels removeAllObjects];
                    self.channelListQuery = [SBDOpenChannel createOpenChannelListQuery];
                    [self loadChannels];
                    [self.loadingActivityIndicator stopAnimating];
                });
            }];
        }
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter a channel name.";
    }];
    
    [alert addAction:closeAction];
    [alert addAction:createAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshChannelList {
    if (self.channelListQuery != nil && self.channelListQuery.isLoading) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.channels removeAllObjects];
    self.channelListQuery = [SBDOpenChannel createOpenChannelListQuery];
    [self loadChannels];
}

- (void)loadChannels {
    if (self.channelListQuery.isLoading) {
        return;
    }
    
    if (!self.channelListQuery.hasNext) {
        return;
    }

    [self.channelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Channel List Loading Error: %@", error);
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            return;
        }
        
        if (channels == nil && [channels count] == 0) {
            return;
        }
        
        for (SBDOpenChannel *channel in channels) {
            [self.channels addObject:channel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.openChatChannelListTableView reloadData];
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
        });
    }];
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
    [vc setSenderId:[SBDMain getCurrentUser].userId];
    [vc setSenderDisplayName:[SBDMain getCurrentUser].nickname];
    [vc setChannel:[self.channels objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDOpenChannel *channel = [self.channels objectAtIndex:indexPath.row];
    OpenChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[OpenChatListTableViewCell cellReuseIdentifier]];
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
    NSLog(@"didStartReconnection in OpenChatListViewController");
}

- (void)didSucceedReconnection {
    NSLog(@"didSucceedReconnection delegate in OpenChatListViewController");
}

- (void)didFailReconnection {
    NSLog(@"didFailReconnection delegate in OpenChatListViewController");
}

#pragma mark - SBDBaseChannelDelegate
- (void)didReceiveMessage:(SBDBaseChannel * _Nonnull)channel message:(SBDBaseMessage * _Nonnull)message {
    NSLog(@"didReceiveMessage:message: delegate in OpenChatListViewController");
}

- (void)didDisappearChannel:(SBDBaseChannel * _Nonnull)channel {
    NSLog(@"didDisappearChannel: delegate in OpenChatListViewController");
}

- (void)didUpdateChannelProperty:(SBDBaseChannel * _Nonnull)channel {
    NSLog(@"didUpdateChannelProperty: delegate in OpenChatListViewController");
}

@end
