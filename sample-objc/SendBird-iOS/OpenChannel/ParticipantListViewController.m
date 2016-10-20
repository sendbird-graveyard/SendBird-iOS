//
//  ParticipantListViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "ParticipantListViewController.h"
#import "ParticipantListTableViewCell.h"

@interface ParticipantListViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SBDUserListQuery *query;
@property (strong, nonatomic) NSMutableArray<SBDUser *> *participants;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ParticipantListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[ParticipantListTableViewCell nib] forCellReuseIdentifier:[ParticipantListTableViewCell cellReuseIdentifier]];
    
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
        self.participants = [[NSMutableArray alloc] init];
        self.query = [self.channel createParticipantListQuery];
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
        
        for (SBDUser *participant in users) {
            [self.participants addObject:participant];
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
    return [self.participants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParticipantListTableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:[ParticipantListTableViewCell cellReuseIdentifier]];
    [cell setModel:self.participants[indexPath.row]];
    
    if (self.participants.count > 0 && indexPath.row + 1 == self.participants.count) {
        [self loadList:NO];
    }
    
    return cell;
}

@end
