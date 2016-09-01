//
//  MemberListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "UserListViewController.h"
#import "UserListTableViewCell.h"
#import "GroupChannelViewController.h"

@interface UserListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<SBDUser *> *users;

@property (atomic) NSString *userID;
@property (atomic) NSString *userName;

@property (strong, nonatomic) SBDUserListQuery *userListQuery;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *selectedMembers;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"User List";
    
    self.users = [[NSMutableArray alloc] init];
    self.selectedMembers = [[NSMutableDictionary alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UserListTableViewCell nib] forCellReuseIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    
    self.userListQuery = [SBDMain createAllUserListQuery];
    
    [self loadMembers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.invitationMode == 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create Channel" style:UIBarButtonItemStylePlain target:self action:@selector(clickCreateChannel:)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(clickInvite:)];
    }
}

- (void)loadMembers {
    if (self.userListQuery.isLoading) {
        return;
    }
    
    if (!self.userListQuery.hasNext) {
        return;
    }
    
    [self.userListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            NSLog(@"User List Loading Error: %@", error);
            return;
        }
        
        if (users == nil || users.count == 0) {
            return;
        }
        
        for (SBDUser *user in users) {
            if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            [self.users addObject:user];
            self.selectedMembers[user.userId] = @(0);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)clickCreateChannel:(id)sender {
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.selectedMembers) {
        if ([[self.selectedMembers objectForKey:key] intValue] == 1) {
            [userIds addObject:key];
        }
    }
    
    if ([userIds count] > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create Group Channel" message:@"Create a group channel." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *createDistinctChannelAction = [UIAlertAction actionWithTitle:@"Create distinct channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SBDGroupChannel createChannelWithUserIds:userIds isDistinct:YES completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%ld: %@", error.code, error.domain] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didCloseUserListViewController:groupChannel:)]) {
                    [self.delegate didCloseUserListViewController:self groupChannel:channel];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:NO];
                });
            }];
        }];
        
        UIAlertAction *createNonDistinctChannelAction = [UIAlertAction actionWithTitle:@"Create non-distinct channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SBDGroupChannel createChannelWithUserIds:userIds isDistinct:NO completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                if (error != nil) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%ld: %@", error.code, error.domain] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didCloseUserListViewController:groupChannel:)]) {
                    [self.delegate didCloseUserListViewController:self groupChannel:channel];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:NO];
                });
            }];
        }];

        [alert addAction:closeAction];
        [alert addAction:createDistinctChannelAction];
        [alert addAction:createNonDistinctChannelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Users" message:@"You have to select users to include" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)clickInvite:(id)sender {
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.selectedMembers) {
        if ([[self.selectedMembers objectForKey:key] intValue] == 1) {
            [userIds addObject:key];
        }
    }

    if ([userIds count] > 0) {
        [self.currentChannel inviteUserIds:userIds completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%ld: %@", error.code, error.domain] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didCloseUserListViewController:groupChannel:)]) {
                    [self.delegate didCloseUserListViewController:self groupChannel:self.currentChannel];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }
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
    SBDUser *user = [self.users objectAtIndex:indexPath.row];
    UITableViewCell* cellCheck = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([[self.selectedMembers objectForKey:user.userId] intValue] == 0) {
        [cellCheck setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.selectedMembers setObject:@(1) forKey:user.userId];
    }
    else {
        [cellCheck setAccessoryType:UITableViewCellAccessoryNone];
        [self.selectedMembers setObject:@(0) forKey:user.userId];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDUser *user = [self.users objectAtIndex:indexPath.row];
    UserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    
    if (cell == nil) {
        cell = [[UserListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListTableViewCell cellReuseIdentifier]];
    }
    
    [cell setModel:user];
    [cell setOnlineStatusVisiblility:YES];
    
    if ([[self.selectedMembers objectForKey:user.userId] intValue] == 1) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    if ([self.users count] > 0) {
        if (indexPath.row == [self.users count] - 1) {
            [self loadMembers];
        }
    }

    return cell;
}

@end
