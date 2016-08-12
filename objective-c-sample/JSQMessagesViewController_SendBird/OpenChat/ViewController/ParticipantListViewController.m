//
//  ParticipantListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 7/28/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "ParticipantListViewController.h"
#import "MemberListTableViewCell.h"

@interface ParticipantListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<SBDUser *> *participants;
@property (strong, nonatomic) SBDUserListQuery *query;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ParticipantListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Participants";
    
    self.participants = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[MemberListTableViewCell nib] forCellReuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    self.query = [self.currentChannel createParticipantListQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshParticipantList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self loadParticipants];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshParticipantList {
    if (self.query != nil && self.query.isLoading) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.participants removeAllObjects];
    self.query = [self.currentChannel createParticipantListQuery];
    [self loadParticipants];
}

- (void)loadParticipants {
    if (self.query.isLoading) {
        return;
    }
    
    if (!self.query.hasNext) {
        return;
    }
    
    [self.query loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable participants, SBDError * _Nullable error) {
        if (error != nil) {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            return;
        }
        
        if (participants == nil || participants.count == 0) {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            return;
        }
        
        for (SBDUser *user in participants) {
            [self.participants addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
        });
    }];
    
    [self.currentChannel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = [NSString stringWithFormat:@"Participants(%lu)", self.currentChannel.participantCount];
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
    SBDUser *user = self.participants[indexPath.row];
    
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
    return [self.participants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBDUser *user = [self.participants objectAtIndex:indexPath.row];
    MemberListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    if (cell == nil) {
        cell = [[MemberListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    }
    
    [cell setModel:user];
    [cell setOnlineStatusVisiblility:NO];
    
    
    if ([self.participants count] > 0) {
        if (indexPath.row == [self.participants count] - 1) {
            [self loadParticipants];
        }
    }
    
    return cell;
}

@end
