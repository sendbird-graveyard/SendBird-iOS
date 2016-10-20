//
//  BannedUserListViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "BlockedUserListViewController.h"
#import "BlockedUserListTableViewCell.h"
#import "NSBundle+SendBird.h"

@interface BlockedUserListViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SBDUserListQuery *query;
@property (strong, nonatomic) NSMutableArray<SBDUser *> *blockedUsers;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation BlockedUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[BlockedUserListTableViewCell nib] forCellReuseIdentifier:[BlockedUserListTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *leftCloseItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftCloseItem];
    
    [self loadList:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshList {
    [self loadList:YES];
}

- (void)loadList:(BOOL)initial {
    if (initial) {
        self.blockedUsers = [[NSMutableArray alloc] init];
        self.query = [SBDMain createBlockedUserListQuery];
    }
    
    if ([self.query hasNext] == NO) {
        return;
    }
    
    [self.query loadNextPageWithCompletionHandler:^(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            return;
        }
        
        for (SBDUser *blockedUser in users) {
            [self.blockedUsers addObject:blockedUser];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)unblockUser:(SBDUser *)user {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *unblokcUserAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"UnblockUserButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SBDMain unblockUser:user completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshList];
            });
        }];
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:unblokcUserAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self unblockUser:self.blockedUsers[indexPath.row]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.blockedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlockedUserListTableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:[BlockedUserListTableViewCell cellReuseIdentifier]];
    [cell setModel:self.blockedUsers[indexPath.row]];
    
    if (self.blockedUsers.count > 0 && indexPath.row + 1 == self.blockedUsers.count) {
        [self loadList:NO];
    }
    
    return cell;
}

@end
