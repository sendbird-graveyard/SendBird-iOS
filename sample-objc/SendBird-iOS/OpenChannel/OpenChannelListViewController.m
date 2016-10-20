//
//  OpenChannelListViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>

#import "OpenChannelListViewController.h"
#import "OpenChannelListTableViewCell.h"
#import "OpenChannelChattingViewController.h"
#import "NSBundle+SendBird.h"

@interface OpenChannelListViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray<SBDOpenChannel *> *channels;
@property (strong, nonatomic) SBDOpenChannelListQuery *openChannelListQuery;

@end

@implementation OpenChannelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[OpenChannelListTableViewCell nib] forCellReuseIdentifier:[OpenChannelListTableViewCell cellReuseIdentifier]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshChannelList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;
    
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    UIBarButtonItem *rightCreateOpenChannelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_plus"] style:UIBarButtonItemStyleDone target:self action:@selector(createOpenChannel)];
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftBackItem];
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, rightCreateOpenChannelItem];
    
    [self refreshChannelList];
}

- (void)refreshChannelList {
    if (self.channels != nil) {
        [self.channels removeAllObjects];
    }
    else {
        self.channels = [[NSMutableArray alloc] init];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    self.openChannelListQuery = [SBDOpenChannel createOpenChannelListQuery];
    self.openChannelListQuery.limit = 20;
    
    [self.openChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
            
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        for (SBDOpenChannel *channel in channels) {
            [self.channels addObject:channel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

- (void)loadChannels {
    if (self.openChannelListQuery.hasNext == NO) {
        return;
    }
    
    [self.openChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        for (SBDOpenChannel *channel in channels) {
            [self.channels addObject:channel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)back {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)createOpenChannel {
    CreateOpenChannelViewController *vc = [[CreateOpenChannelViewController alloc] init];
    vc.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:NO completion:nil];
    });
}

#pragma mark - CreateOpenChannelViewControllerDelegate
- (void)refreshView:(UIViewController *)vc {
    [self refreshChannelList];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
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
    [self.channels[indexPath.row] enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        OpenChannelChattingViewController *vc = [[OpenChannelChattingViewController alloc] init];
        vc.channel = self.channels[indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:NO completion:nil];
        });
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpenChannelListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[OpenChannelListTableViewCell cellReuseIdentifier]];
    
    [cell setModel:self.channels[indexPath.row]];
    [cell setRow:indexPath.row];
    
    if (self.channels.count > 0 && indexPath.row + 1 == self.channels.count) {
        [self loadChannels];
    }
    
    return cell;
}

@end
