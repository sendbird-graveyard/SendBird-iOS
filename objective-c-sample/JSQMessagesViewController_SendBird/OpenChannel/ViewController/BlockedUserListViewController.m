//
//  BlockedUserListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 8/11/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "BlockedUserListViewController.h"
#import "UserListTableViewCell.h"

@interface BlockedUserListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<SBDUser *> *blockedUsers;
@property (strong, nonatomic) SBDUserListQuery *query;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation BlockedUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Blocked Users";
    
    self.blockedUsers = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UserListTableViewCell nib] forCellReuseIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    
    self.query = [SBDMain createBlockedUserListQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshBlockedUsers) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self loadBlockedUsers];
}

- (void)refreshBlockedUsers {
    if (self.query != nil && self.query.isLoading) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.blockedUsers removeAllObjects];
    self.query = [SBDMain createBlockedUserListQuery];
    [self loadBlockedUsers];
}

- (void)loadBlockedUsers {
    if (self.query.isLoading) {
        return;
    }
    
    if (!self.query.hasNext) {
        return;
    }
    
    [self.query loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            return;
        }
        
        if (users == nil || users.count == 0) {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            return;
        }
        
        for (SBDUser *user in users) {
            [self.blockedUsers addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SBDUser *user = self.blockedUsers[indexPath.row];
    
    if (user == nil || [user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *unblockUserAction = nil;
    unblockUserAction = [UIAlertAction actionWithTitle:@"Unblock user" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [SBDMain unblockUser:user completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%ld: %@", error.code, error.domain] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
            else {
                [self.blockedUsers removeObject:user];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }];
    
    [alert addAction:closeAction];
    [alert addAction:unblockUserAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.blockedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDUser *user = [self.blockedUsers objectAtIndex:indexPath.row];
    UserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    
    if (cell == nil) {
        cell = [[UserListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    }
    
    [cell setModel:user];
    [cell setOnlineStatusVisiblility:NO];
    
    if ([self.blockedUsers count] > 0) {
        if (indexPath.row == [self.blockedUsers count] - 1) {
            [self loadBlockedUsers];
        }
    }
    
    return cell;
}

@end
