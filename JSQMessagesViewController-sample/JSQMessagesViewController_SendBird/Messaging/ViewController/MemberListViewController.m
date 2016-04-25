//
//  MemberListViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MemberListViewController.h"
#import "MemberListTableViewCell.h"
#import "MessagingViewController.h"

@interface MemberListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *memberListTableView;

@property (strong, nonatomic) NSMutableArray<SendBirdAppUser *> *members;
@property (atomic) BOOL isLoading;
@property (atomic) BOOL hasNext;

@property (atomic) NSString *userID;
@property (atomic) NSString *userName;

@property (strong, nonatomic) SendBirdUserListQuery *memberListQuery;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *selectedMembers;

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.isLoading = NO;
    self.hasNext = YES;
    
    self.members = [[NSMutableArray alloc] init];
    self.selectedMembers = [[NSMutableDictionary alloc] init];
    
    self.memberListTableView.delegate = self;
    self.memberListTableView.dataSource = self;
    [self.memberListTableView registerNib:[MemberListTableViewCell nib] forCellReuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    [SendBird loginWithUserId:self.userID andUserName:self.userName];
    self.memberListQuery = [SendBird queryUserList];
    
    [self loadMembers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)loadMembers {
    if (self.isLoading) {
        return;
    }
    
    if (!self.hasNext) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.memberListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        if ([queryResult count] > 0) {
            self.hasNext = YES;
        }
        else {
            self.hasNext = NO;
        }
        
        for (SendBirdAppUser *item in queryResult) {
            [self.members addObject:item];
            [self.selectedMembers setObject:@(0) forKey:[item guestId]];
        }
        
        [self.memberListTableView reloadData];
        
        self.isLoading = NO;
    } endBlock:^(NSInteger code) {
        self.isLoading = NO;
    }];
}

- (void)setUserID:(NSString *)aUserID userName:(NSString *)aUserName {
    self.userID = aUserID;
    self.userName = aUserName;
}

- (IBAction)clickInvite:(id)sender {
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.selectedMembers) {
        NSLog(@"Key: %@", key);
        if ([[self.selectedMembers objectForKey:key] intValue] == 1) {
            [userIds addObject:key];
        }
    }

    if ([userIds count] > 0) {
        MessagingViewController *vc = [[MessagingViewController alloc] init];
        [vc setTitle:@"Messaging Channel"];
        [vc setSenderId:[SendBird getUserId]];
        [vc setSenderDisplayName:[SendBird getUserName]];
        [vc inviteUsers:userIds];
        [self presentViewController:vc animated:YES completion:^{
            
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
    SendBirdAppUser *user = [self.members objectAtIndex:indexPath.row];
    UITableViewCell* cellCheck = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([[self.selectedMembers objectForKey:[user guestId]] intValue] == 0) {
        [cellCheck setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.selectedMembers setObject:@(1) forKey:[user guestId]];
    }
    else {
        [cellCheck setAccessoryType:UITableViewCellAccessoryNone];
        [self.selectedMembers setObject:@(0) forKey:[user guestId]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SendBirdAppUser *user = [self.members objectAtIndex:indexPath.row];
    MemberListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    if (cell == nil) {
        cell = [[MemberListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    }
    
    [cell setModel:user];
    
    if ([[self.selectedMembers objectForKey:[user guestId]] intValue] == 1) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    if ([self.members count] > 0) {
        if (indexPath.row == [self.members count] - 1) {
            [self loadMembers];
        }
    }

    return cell;
}


@end
