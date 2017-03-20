//
//  MemberListViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "MemberListViewController.h"
#import "MemberListTableViewCell.h"
#import "NSBundle+SendBird.h"

@interface MemberListViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[MemberListTableViewCell nib] forCellReuseIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *leftCloseItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftCloseItem];
    
    [SBDMain addChannelDelegate:self identifier:self.description];
    [SBDMain addConnectionDelegate:self identifier:self.description];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"MemberListTitle"], (int)self.channel.memberCount];
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection {
    
}

- (void)didSucceedReconnection {
    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"MemberListTitle"], (int)self.channel.memberCount];
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)didFailReconnection {

}

#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {

}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {

}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {

}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"MemberListTitle"], (int)self.channel.memberCount];
        [self.tableView reloadData];
    });
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"MemberListTitle"], (int)self.channel.memberCount];
        [self.tableView reloadData];
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"MemberListTitle"], (int)self.channel.memberCount];
        [self.tableView reloadData];
    });
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {

}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {

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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channel.members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MemberListTableViewCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:[MemberListTableViewCell cellReuseIdentifier]];
    [cell setModel:self.channel.members[indexPath.row]];
    
    return cell;
}

@end
