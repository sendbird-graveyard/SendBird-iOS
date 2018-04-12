//
//  GroupChannelListViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeButton.h>

#import "GroupChannelListViewController.h"
#import "GroupChannelListTableViewCell.h"
#import "GroupChannelListEditableTableViewCell.h"
#import "GroupChannelChattingViewController.h"
#import "NSBundle+SendBird.h"
#import "Constants.h"
#import "Utils.h"
#import "ConnectionManager.h"

@interface GroupChannelListViewController () <ConnectionManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *noChannelLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray<SBDGroupChannel *> *channels;

@property (atomic) BOOL editableChannel;
@property (strong, nonatomic) SBDGroupChannelListQuery *groupChannelListQuery;
@property (strong, nonatomic) NSMutableArray<NSString *> *typingAnimationChannelList;

@property (atomic) BOOL cachedChannels;

@property (atomic) BOOL firstLoading;

@end

@implementation GroupChannelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.editableChannel = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.editing = NO;
    [self.tableView registerNib:[GroupChannelListTableViewCell nib] forCellReuseIdentifier:[GroupChannelListTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[GroupChannelListEditableTableViewCell nib] forCellReuseIdentifier:[GroupChannelListEditableTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannelList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self setDefaultNavigationItems];
    
    self.typingAnimationChannelList = [[NSMutableArray alloc] init];
    self.noChannelLabel.hidden = YES;
    
    self.cachedChannels = YES;
    
    [ConnectionManager addConnectionObserver:self];
    if ([SBDMain getConnectState] == SBDWebSocketClosed) {
        [ConnectionManager loginWithCompletionHandler:^(SBDUser * _Nullable user, NSError * _Nullable error) {
            if (error != nil) {
                return;
            }
        }];
    }
    else {
        self.firstLoading = NO;
        [self showList];
    }
}

- (void)dealloc {
    [ConnectionManager removeConnectionObserver:self];
}

- (void)showList {
    dispatch_queue_t dumpLoadQueue = dispatch_queue_create("com.sendbird.dumploadqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dumpLoadQueue, ^{
        self.channels = [[NSMutableArray alloc] initWithArray:[Utils loadGroupChannels]];
        if (self.channels.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    [self refreshChannelList];
                });
                
            });
        }
        else {
            self.cachedChannels = NO;
            [self refreshChannelList];
        }
        self.firstLoading = YES;
    });
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Utils dumpChannels:self.channels];
}

- (void)addDelegates {
    [SBDMain addChannelDelegate:self identifier:self.description];
}

- (void)setDefaultNavigationItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;
    
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    UIBarButtonItem *rightCreateGroupChannelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_plus"] style:UIBarButtonItemStyleDone target:self action:@selector(createGroupChannel)];
    UIBarButtonItem *rightEditItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_edit"] style:UIBarButtonItemStyleDone target:self action:@selector(editGroupChannel)];
    rightEditItem.imageInsets = UIEdgeInsetsMake(0, 14, 0, -14);
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftBackItem];
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, rightCreateGroupChannelItem, rightEditItem];
}

- (void)setEditableNavigationItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
  
    UIBarButtonItem *leftDoneItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle sbLocalizedStringForKey:@"DoneButton"] style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [leftDoneItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftDoneItem];
    self.navItem.rightBarButtonItems = @[];
}

- (void)refreshChannelList {
    self.groupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
    self.groupChannelListQuery.limit = 20;
    self.groupChannelListQuery.order = SBDGroupChannelListOrderLatestLastMessage;
    
    [self.groupChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });

            return;
        }

        if (self.channels != nil) {
            [self.channels removeAllObjects];
        }
        else {
            self.channels = [[NSMutableArray alloc] init];
        }
        
        self.cachedChannels = NO;
        
        for (SBDGroupChannel *channel in channels) {
            [self.channels addObject:channel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.channels.count == 0) {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                self.noChannelLabel.hidden = NO;
            }
            else {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                self.noChannelLabel.hidden = YES;
            }
            
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

- (void)loadChannels {
    if (self.cachedChannels == YES) {
        return;
    }
    
    if (self.groupChannelListQuery != nil) {
        if ([self.groupChannelListQuery hasNext] == NO) {
            return;
        }
        
        [self.groupChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
            if (error != nil) {
                if (error.code != SBDErrorQueryInProgress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                    });
                    
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                }
                
                return;
            }
            
            for (SBDGroupChannel *channel in channels) {
                [self.channels addObject:channel];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)back {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)createGroupChannel {
    CreateGroupChannelUserListViewController *vc = [[CreateGroupChannelUserListViewController alloc] init];
    vc.delegate = self;
    vc.userSelectionMode = 0;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)editGroupChannel {
    self.editableChannel = YES;
    [self setEditableNavigationItems];
    [self.tableView reloadData];
}

- (void)done {
    self.editableChannel = NO;
    [self setDefaultNavigationItems];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
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
    if (self.editableChannel == NO) {
        GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
        vc.channel = self.channels[indexPath.row];

        [self presentViewController:vc animated:NO completion:nil];
    }
    else {
        MGSwipeTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell showSwipe:MGSwipeDirectionRightToLeft animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell *cell = nil;
    if (self.editableChannel) {
        cell = [tableView dequeueReusableCellWithIdentifier:[GroupChannelListEditableTableViewCell cellReuseIdentifier]];
        MGSwipeButton *leaveButton = [MGSwipeButton buttonWithTitle:[NSBundle sbLocalizedStringForKey:@"LeaveButton"] backgroundColor:[Constants leaveButtonColor]];
        MGSwipeButton *hideButton = [MGSwipeButton buttonWithTitle:[NSBundle sbLocalizedStringForKey:@"HideButton"] backgroundColor:[Constants hideButtonColor]];
        
        hideButton.titleLabel.font = [Constants hideButtonFont];
        leaveButton.titleLabel.font = [Constants leaveButtonFont];
        
        cell.rightButtons = @[hideButton, leaveButton];
        [(GroupChannelListEditableTableViewCell *)cell setModel:self.channels[indexPath.row]];
        cell.delegate = self;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:[GroupChannelListTableViewCell cellReuseIdentifier]];
        if (self.channels[indexPath.row].isTyping == YES) {
            if ([self.typingAnimationChannelList indexOfObject:self.channels[indexPath.row].channelUrl] == NSNotFound) {
                [self.typingAnimationChannelList addObject:self.channels[indexPath.row].channelUrl];
            }
        }
        else {
            [self.typingAnimationChannelList removeObject:self.channels[indexPath.row].channelUrl];
        }

        [(GroupChannelListTableViewCell *)cell setModel:self.channels[indexPath.row]];
    }
    
    if (self.channels.count > 0 && indexPath.row + 1 == self.channels.count) {
        [self loadChannels];
    }
    
    return cell;
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL) swipeTableCell:(MGSwipeTableCell *) cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    // 0: right, 1: left
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    SBDGroupChannel *selectedChannel = self.channels[row];
    if (index == 0) {
        // Hide
        [selectedChannel hideChannelWithHidePreviousMessages:NO completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            [self.channels removeObject:selectedChannel];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    else {
        // Leave
        [selectedChannel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            [self.channels removeObject:selectedChannel];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    
    return YES;
}

#pragma mark - CreateGroupChannelUserListViewControllerDelegate
- (void)openGroupChannel:(SBDGroupChannel *)channel viewController:(UIViewController *)vc {
    dispatch_async(dispatch_get_main_queue(), ^{
        GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
        vc.channel = channel;
        [self presentViewController:vc animated:NO completion:nil];
    });
}

#pragma mark - Connection Manager Delegate
- (void)didConnect:(BOOL)isReconnection {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *bestVC = [Utils findBestViewController:vc];
    
    if (bestVC == self) {
        [self refreshChannelList];
    }
}

#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if ([sender isKindOfClass:[SBDGroupChannel class]]) {
        SBDGroupChannel *messageReceivedChannel = (SBDGroupChannel *)sender;
        if ([self.channels indexOfObject:messageReceivedChannel] != NSNotFound) {
            [self.channels removeObject:messageReceivedChannel];
        }
        [self.channels insertObject:messageReceivedChannel atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    if (self.editableChannel == YES) {
        return;
    }
    
    NSUInteger row = [self.channels indexOfObject:sender];
    if (row != NSNotFound) {
        GroupChannelListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        
        [cell startTypingAnimation];
    }
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.channels indexOfObject:sender] == NSNotFound) {
            [self.channels addObject:sender];
        }
        [self.tableView reloadData];
    });
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        [self.channels removeObject:sender];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidExit:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasMuted:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnmuted:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasBanned:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnbanned:(SBDUser * _Nonnull)user {
    
}

- (void)channelWasFrozen:(SBDOpenChannel * _Nonnull)sender {
    
}

- (void)channelWasUnfrozen:(SBDOpenChannel * _Nonnull)sender {
    
}

- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    if ([sender isKindOfClass:[SBDGroupChannel class]]) {
        SBDGroupChannel *messageReceivedChannel = (SBDGroupChannel *)sender;
        if ([self.channels indexOfObject:messageReceivedChannel] != NSNotFound) {
            [self.channels removeObject:messageReceivedChannel];
        }
        [self.channels insertObject:messageReceivedChannel atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    
}


@end
