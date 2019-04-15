//
//  MemberListViewController.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "MemberListViewController.h"
#import "MemberListTableViewCell.h"
#import "ConnectionManager.h"

@interface MemberListViewController () <SBDChannelDelegate, ConnectionManagerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, atomic, nonnull) NSString *identifier;

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
    
    self.identifier = [[NSUUID UUID] UUIDString];
    [SBDMain addChannelDelegate:self identifier:self.identifier];
    [ConnectionManager addConnectionObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navItem.title = [NSString stringWithFormat:@"Members (%d)", (int)self.channel.memberCount];
            [self.tableView reloadData];
        });
    }];
}

- (void)dealloc {
    [SBDMain removeChannelDelegateForIdentifier:self.identifier];
    [ConnectionManager removeConnectionObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Connection Manager Delegate
- (void)didConnect:(BOOL)isReconnection {
    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navItem.title = [NSString stringWithFormat:@"Members (%d)", (int)self.channel.memberCount];
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - SBDChannelDelegate
- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    if (![self.channel.channelUrl isEqualToString:sender.channelUrl]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navItem.title = [NSString stringWithFormat:@"Members (%d)", (int)self.channel.memberCount];
        [self.tableView reloadData];
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
