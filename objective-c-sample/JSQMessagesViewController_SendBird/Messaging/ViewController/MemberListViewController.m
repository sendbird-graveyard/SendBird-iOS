//
//  MemberListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 8/11/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MemberListViewController.h"
#import "MemberListTableViewCell.h"

@interface MemberListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<SBDUser *> *members;
@property (strong, nonatomic) SBDUserListQuery *query;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Members";
    
    self.members = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[MemberListTableViewCell nib] forCellReuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshMembers) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self refreshMembers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshMembers {
    [self.refreshControl beginRefreshing];
    [self.currentChannel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
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
    SBDUser *user = self.currentChannel.members[indexPath.row];
    
    if (user == nil || [user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *blockUserAction = nil;
    blockUserAction = [UIAlertAction actionWithTitle:@"Block user" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [SBDMain blockUser:user completionHandler:^(SBDUser * _Nullable blockedUser, SBDError * _Nullable error) {
            if (error != nil) {
                
            }
            else {
                
            }
        }];
    }];
    
    [alert addAction:closeAction];
    [alert addAction:blockUserAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentChannel.members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDUser *user = [self.currentChannel.members objectAtIndex:indexPath.row];
    MemberListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    if (cell == nil) {
        cell = [[MemberListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    }
    
    [cell setModel:user];
    [cell setOnlineStatusVisiblility:YES];

    return cell;
}

@end
