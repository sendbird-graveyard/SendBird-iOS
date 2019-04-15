//
//  GroupChannelListViewController.m
//  SendBird-iOS-LocalCache-Sample
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
#import "ConnectionManager.h"
#import <SendBirdSyncManager/SendBirdSyncManager.h>
#import "Utils+SBDObject.h"
#import "Utils+View.h"

@interface GroupChannelListViewController () <SBDChannelDelegate, SBSMChannelCollectionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *noChannelLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, atomic, nonnull) NSMutableArray<SBDGroupChannel *> *channels;

@property (atomic) BOOL editableChannel;
@property (strong, nonatomic) NSMutableArray<NSString *> *typingAnimationChannelList;

@property (copy, atomic, nonnull) NSString *identifier;

@property (strong, nonatomic, nonnull) SBSMOperationQueue *tableViewQueue;

/**
 *  new properties with channel manager
 */
@property (strong, nonatomic, nullable) SBSMChannelCollection *channelCollection;

@end

@implementation GroupChannelListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        _channels = [NSMutableArray array];
        _tableViewQueue = [SBSMOperationQueue queue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureView];
    
    self.editableChannel = NO;
    
    self.typingAnimationChannelList = [[NSMutableArray alloc] init];
    self.noChannelLabel.hidden = YES;
    
    self.identifier = [[NSUUID UUID] UUIDString];
    [SBDMain addChannelDelegate:self identifier:self.identifier];
    
    self.channelCollection.delegate = self;
    // start loading progress
    [self.channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
        // end loading progress
    }];
}

- (void)configureView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.editing = NO;
    [self.tableView registerNib:[GroupChannelListTableViewCell nib] forCellReuseIdentifier:[GroupChannelListTableViewCell cellReuseIdentifier]];
    [self.tableView registerNib:[GroupChannelListEditableTableViewCell nib] forCellReuseIdentifier:[GroupChannelListEditableTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannel) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self setDefaultNavigationItems];
}

- (void)dealloc {
    if (self.channelCollection != nil) {
        self.channelCollection.delegate = nil;
    }
    
    [SBDMain removeChannelDelegateForIdentifier:self.identifier];
    [self.channelCollection remove];
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

- (SBSMChannelCollection *)channelCollection {
    if (_channelCollection == nil) {
        _channelCollection = [self createChannelCollection];
    }
    return _channelCollection;
}

- (SBSMChannelCollection *)createChannelCollection {
    SBSMChannelCollection *collection = [SBSMChannelCollection collectionWithQuery:self.query];
    return collection;
}

- (void)resetChannelCollection {
    [self.channelCollection remove];
    self.channelCollection = nil;
}

- (SBDGroupChannelListQuery *)query {
    SBDGroupChannelListQuery *query = [SBDGroupChannel createMyGroupChannelListQuery];
    query.limit = 10;
    query.order = SBDGroupChannelListOrderLatestLastMessage;
    return query;
}

- (void)refreshChannel {
    // start loading progress
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
    });

    [self resetChannelCollection];
    [self.channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
        // end loading progress
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }];
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

- (void)setEditableNavigationItems {
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    
    UIBarButtonItem *leftDoneItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle sbLocalizedStringForKey:@"DoneButton"] style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [leftDoneItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftDoneItem];
    self.navItem.rightBarButtonItems = @[];
}

- (void)done {
    self.editableChannel = NO;
    [self setDefaultNavigationItems];
    [self.tableView reloadData];
}

- (void)hideEmptyTableStyle {
//    if (self.channels.count > 0 && self.noChannelLabel.hidden) {
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        self.noChannelLabel.hidden = YES;
//    }
}

- (void)showEmptyTableStyle {
    if (self.channels.count == 0 && !self.noChannelLabel.hidden) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.noChannelLabel.hidden = NO;
    }
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
    if (self.editableChannel) {
        MGSwipeTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell showSwipe:MGSwipeDirectionRightToLeft animated:YES];
    }
    else {
        GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
        vc.channel = self.channels[indexPath.row];
        
        [self presentViewController:vc animated:NO completion:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
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
            
            SBDGroupChannel *channel = self.channels[indexPath.row];
            [(GroupChannelListTableViewCell *)cell setModel:channel];
        }
        
        if (self.channels.count > 0 && indexPath.row + 1 == self.channels.count) {
            // start loading progress
            [self.channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
                // end loading progress
            }];
        }
        
        return cell;
    }
    @catch (NSException *e) {
        NSLog(@"****** [TABLE VIEW] exception: %@", e);
        return nil;
    }
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *) cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    // 0: right, 1: left
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    SBDGroupChannel *selectedChannel = self.channels[row];
    
    void (^handler)(SBDError *) = ^void (SBDError * error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
    };
    
    if (index == 0) {
        // Hide
        [selectedChannel hideChannelWithHidePreviousMessages:NO completionHandler:handler];
    }
    else {
        // Leave
        [selectedChannel leaveChannelWithCompletionHandler:handler];
    }
    
    return YES;
}

#pragma mark - CreateGroupChannelUserListViewControllerDelegate
- (void)presentGroupChannel:(SBDGroupChannel *)channel onViewController:(UIViewController *)parentViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
        vc.channel = channel;
        [self presentViewController:vc animated:NO completion:nil];
    });
}

#pragma mark - Channel Query Collection Delegate
- (void)collection:(SBSMChannelCollection *)collection didReceiveEvent:(SBSMChannelEventAction)action channels:(NSArray<SBDGroupChannel *> *)channels {
    if (self.channelCollection != collection || channels.count == 0) {
        return;
    }
    
    __block SBSMOperation *operation = [self.tableViewQueue enqueue:^{
        SBSMVoidHandler handler = ^void (void) {
            [operation complete];
        };
        
        switch (action) {
            case SBSMChannelEventActionClear: {
                [self clearAllChannelsWithCompletionHandler:handler];
                break;
            }
            case SBSMChannelEventActionInsert: {
                [self insertChannels:channels completionHandler:^{
                    [self hideEmptyTableStyle];
                    handler();
                }];
                break;
            }
            case SBSMChannelEventActionUpdate: {
                [self updateChannels:channels completionHandler:handler];
                break;
            }
            case SBSMChannelEventActionRemove: {
                [self removeChannels:channels completionHandler:^{
                    [self showEmptyTableStyle];
                    handler();
                }];
                break;
            }
            case SBSMChannelEventActionMove: {
                [self moveChannel:channels.firstObject completionHandler:handler];
                break;
            }
            case SBSMChannelEventActionNone:
            default: {
                // pass
                handler();
                break;
            }
        }
    }];
}

#pragma mark - UI Update with Change Log
- (void)insertChannels:(NSArray <SBDGroupChannel *> *)channels completionHandler:(SBSMVoidHandler)completionHandler {
    if (channels.count == 0) {
        return;
    }
    
    NSLog(@"== [Channel List View] will insert tableView's channel - tableView: %@ - channels: %@", self.channels, channels);
    [self.channels addObjectsFromArray:channels];
    [self.channels sortUsingComparator:self.channelCollection.comparator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        if (completionHandler != nil) {
            completionHandler();
        }
    });
}

- (void)updateChannels:(NSArray <SBDGroupChannel *> *)channels completionHandler:(SBSMVoidHandler)completionHandler {
    if (channels.count == 0) {
        return;
    }
    
    NSLog(@"== [Channel List View] will update tableView's channel - tableView: %@ - channels: %@", self.channels, channels);
    for (SBDGroupChannel *updatedChannel in channels) {
        for (SBDGroupChannel *channel in self.channels) {
            if ([channel.channelUrl isEqualToString:updatedChannel.channelUrl] && channel != updatedChannel) {
                NSUInteger index = [self.channels indexOfObject:channel];
                [self.channels replaceObjectAtIndex:index withObject:updatedChannel];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        if (completionHandler != nil) {
            completionHandler();
        }
    });
}

- (void)removeChannels:(NSArray<SBDGroupChannel *> *)channels completionHandler:(SBSMVoidHandler)completionHandler {
    if (channels.count == 0) {
        return;
    }
    
    NSLog(@"== [Channel List View] will remove tableView's channel - tableView: %@ - channels: %@", self.channels, channels);
    NSMutableArray<NSString *> *removedChannelUrls = [[channels valueForKey:@"channelUrl"] mutableCopy];
    NSIndexSet *indexSet = [self.channels indexesOfObjectsPassingTest:^BOOL(SBDGroupChannel * _Nonnull channel, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([removedChannelUrls containsObject:channel.channelUrl]) {
            [removedChannelUrls removeObject:channel.channelUrl];
            if (removedChannelUrls.count == 0) {
                *stop = YES;
            }
            return YES;
        }
        
        return NO;
    }];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }];
    
    [Utils tableView:self.tableView performBatchUpdates:^(UITableView * _Nonnull tableView) {
        [tableView deleteRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.channels removeObjectsAtIndexes:indexSet];
    } completion:^(BOOL finished) {
        if (completionHandler != nil) {
            completionHandler();
        }
    }];
}

- (void)moveChannel:(SBDGroupChannel *)channel completionHandler:(SBSMVoidHandler)completionHandler {
    __block NSUInteger oldIndex = NSNotFound;
    [self.channels enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SBDGroupChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([channel.channelUrl isEqualToString:obj.channelUrl]) {
            oldIndex = idx;
            *stop = YES;
        }
    }];
    
    if (oldIndex == NSNotFound) {
        if (completionHandler != nil) {
            completionHandler();
        }
        return;
    }
    
    [self.channels replaceObjectAtIndex:oldIndex withObject:channel];
    
    [self.channels sortUsingComparator:self.channelCollection.comparator];
    
    __block NSUInteger newIndex = NSNotFound;
    [self.channels enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SBDGroupChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([channel.channelUrl isEqualToString:obj.channelUrl]) {
            newIndex = idx;
            *stop = YES;
        }
    }];
    
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
        
        if (completionHandler != nil) {
            completionHandler();
        }
    });
}

- (void)clearAllChannelsWithCompletionHandler:(SBSMVoidHandler)completionHandler {
    NSLog(@"== [Channel List View] will clear tableView's channel - tableView: %@", self.channels);
    [Utils tableView:self.tableView performBatchUpdates:^(UITableView * _Nonnull tableView) {
        NSLog(@"== [Channel List View] will remove all tableView - tableView: %@", self.channels);
        [self.channels removeAllObjects];
        [tableView reloadData];
        NSLog(@"== [Channel List View] did remove all tableView - tableView: %@", self.channels);
    } completion:^(BOOL finished) {
        if (completionHandler != nil) {
            completionHandler();
        }
    }];
}

#pragma mark - SBDChannelDelegate
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

@end
