//
//  CreateGroupChannelUserListViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>

#import "CreateGroupChannelUserListViewController.h"
#import "SelectedUserListCollectionViewCell.h"
#import "CreateGroupChannelUserListTableViewCell.h"
#import "CreateGroupChannelSelectOptionViewController.h"
#import "NSBundle+SendBird.h"
#import "Constants.h"

@interface CreateGroupChannelUserListViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UICollectionView *selectedUserListCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *userListTableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray<SBDUser *> *users;
@property (strong, nonatomic) SBDUserListQuery *userListQuery;
@property (strong, nonatomic) NSMutableArray<SBDUser *> *selectedUsers;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedUserListHeight;

@end

@implementation CreateGroupChannelUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;

    UIBarButtonItem *leftCloseItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    UIBarButtonItem *rightNextItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle sbLocalizedStringForKey:@"NextButton"] style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    [rightNextItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftCloseItem];
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, rightNextItem];

    self.selectedUserListCollectionView.contentInset = UIEdgeInsetsMake(0, 14, 0, 14);
    self.selectedUserListCollectionView.delegate = self;
    self.selectedUserListCollectionView.dataSource = self;
    [self.selectedUserListCollectionView registerNib:[SelectedUserListCollectionViewCell nib] forCellWithReuseIdentifier:[SelectedUserListCollectionViewCell cellReuseIdentifier]];
    self.selectedUserListHeight.constant = 0;
    self.selectedUserListCollectionView.hidden = YES;
    
    self.userListTableView.delegate = self;
    self.userListTableView.dataSource = self;
    [self.userListTableView registerNib:[CreateGroupChannelUserListTableViewCell nib] forCellReuseIdentifier:[CreateGroupChannelUserListTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshUserList) forControlEvents:UIControlEventValueChanged];
    [self.userListTableView addSubview:self.refreshControl];
    
    self.selectedUsers = [[NSMutableArray alloc] init];

    [self.view layoutIfNeeded];
    
    [self loadUserList:YES];
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)next {
    if (self.selectedUsers.count == 0) {
        return;
    }
    
    CreateGroupChannelSelectOptionViewController *vc = [[CreateGroupChannelSelectOptionViewController alloc] init];
    vc.selectedUser = [[NSArray alloc] initWithArray:self.selectedUsers];
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)refreshUserList {
    [self loadUserList:YES];
}

- (void)loadUserList:(BOOL)initial {
    if (initial == YES) {
        if (self.users == nil) {
            self.users = [[NSMutableArray alloc] init];
        }
        
        if (self.selectedUsers == nil) {
            self.selectedUsers = [[NSMutableArray alloc] init];
        }
        
        [self.selectedUsers removeAllObjects];
        [self.users removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedUserListHeight.constant = 0;
            self.selectedUserListCollectionView.hidden = YES;
            
            [self.userListTableView reloadData];
            [self.selectedUserListCollectionView reloadData];
        });
        
        self.userListQuery = nil;
    }
    
    if (self.userListQuery == nil) {
        self.userListQuery = [SBDMain createAllUserListQuery];
        self.userListQuery.limit = 25;
    }
    
    if (self.userListQuery.hasNext == NO) {
        [self.refreshControl endRefreshing];
        return;
    }

    [self.userListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            [self.refreshControl endRefreshing];
            
            return;
        }
        
        for (SBDUser *user in users) {
            if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            [self.users addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userListTableView reloadData];
        });
        
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedUsers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectedUserListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SelectedUserListCollectionViewCell cellReuseIdentifier] forIndexPath:indexPath];
    [cell setModel:self.selectedUsers[indexPath.row]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SBDUser *selectedUser = self.selectedUsers[indexPath.row];
    [self.selectedUsers removeObject:selectedUser];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.selectedUsers.count == 0) {
            self.selectedUserListHeight.constant = 0;
            self.selectedUserListCollectionView.hidden = YES;
        }
        [collectionView reloadData];
        [self.userListTableView reloadData];
    });
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
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
    SBDUser *selectedUser = self.users[indexPath.row];
    
    if ([self.selectedUsers indexOfObject:selectedUser] == NSNotFound) {
        [self.selectedUsers addObject:selectedUser];
    }
    else {
        [self.selectedUsers removeObject:selectedUser];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.selectedUsers.count > 0) {
            self.selectedUserListHeight.constant = 90;
            self.selectedUserListCollectionView.hidden = NO;
        }
        else {
            self.selectedUserListHeight.constant = 0;
            self.selectedUserListCollectionView.hidden = YES;
        }
        
        [self.userListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.selectedUserListCollectionView reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CreateGroupChannelUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CreateGroupChannelUserListTableViewCell cellReuseIdentifier]];
    [cell setModel:self.users[indexPath.row]];
    
    if ([self.selectedUsers indexOfObject:self.users[indexPath.row]] == NSNotFound) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setSelectedUser:NO];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setSelectedUser:YES];
        });
    }
    
    if (self.users.count > 0 && indexPath.row + 1 == self.users.count) {
        [self loadUserList:NO];
    }
    
    return cell;
}

#pragma mark - CreateGroupChannelSelectOptionViewControllerDelegate
- (void)didFinishCreatingGroupChannel:(SBDGroupChannel *)channel viewController:(UIViewController *)vc {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.delegate != nil) {
            [self.delegate openGroupChannel:channel viewController:self];
        }
    }];
}

@end
