//
//  ChannelListTableView.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "ChannelListTableView.h"

@interface ChannelListTableView ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    SendBirdChannelListQuery *channelListQuery;
}

@end

@implementation ChannelListTableView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initView];
    }
    return self;
}

- (void) initView
{
    [self setBackgroundColor:[UIColor whiteColor]];
    self.searchAreaView = [[UIView alloc] init];
    [self.searchAreaView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.searchAreaView setBackgroundColor:UIColorFromRGB(0x2ac6b6)];
    self.searchTextField = [[UITextField alloc] init];
    [self.searchTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.searchTextField setBackground:[UIImage imageNamed:@"_box_white"]];
    [self.searchTextField setTextColor:[UIColor blackColor]];
    [self.searchTextField setFont:[UIFont systemFontOfSize:13.0]];
    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 8)];
    UIView *rightPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 8)];
    [self.searchTextField setLeftView:leftPaddingView];
    [self.searchTextField setRightView:rightPaddingView];
    [self.searchTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.searchTextField setRightViewMode:UITextFieldViewModeAlways];
    [self.searchTextField setReturnKeyType:UIReturnKeySearch];
    [self.searchTextField setDelegate:self];
    [self.searchTextField addTarget:self action:@selector(searchTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"  Search"];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageNamed:@"_icon_search"];
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
    [self.searchTextField setAttributedPlaceholder:attributedString];
    
    self.channelTableView = [[UITableView alloc] init];
    [self.channelTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.channelTableView setDelegate:self];
    [self.channelTableView setDataSource:self];
    [self.channelTableView setSeparatorColor:[UIColor clearColor]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadChannels) forControlEvents:UIControlEventValueChanged];
    
    [self.searchAreaView addSubview:self.searchTextField];
    [self addSubview:self.searchAreaView];
    
    [self.channelTableView addSubview:self.refreshControl];
    [self addSubview:self.channelTableView];
    
    [self applyConstraints];
}

- (void)viewDidLoad
{
    channelListQuery = [SendBird queryChannelList];
    self.channels = [[NSMutableArray alloc] init];
    [ImageCache initImageCache];
}

- (void) applyConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchAreaView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchAreaView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchAreaView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchAreaView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:43]];
    
    [self.searchAreaView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.searchAreaView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.searchAreaView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.searchAreaView attribute:NSLayoutAttributeLeading multiplier:1 constant:8]];
    [self.searchAreaView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.searchAreaView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchAreaView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.channelTableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.channelTableView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.channelTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.channelTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

- (void) loadChannels
{
    if ([channelListQuery isLoading]) {
        return;
    }
    
    if (![channelListQuery hasNext]) {
        return;
    }
    
    [channelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        if ([channelListQuery page] == 1) {
            [self.channels removeAllObjects];
        }
        [self.channels addObjectsFromArray:queryResult];
        
        [self.channelTableView reloadData];
        [self.refreshControl endRefreshing];
    } endBlock:^(NSError *error) {
        NSLog(@"Error");
    }];
}

- (void) reloadChannels
{
    //    [[[SendBird sharedInstance] taskQueue] cancelAllOperations];
    [self.chattingTableViewController setIndicatorHidden:NO];
    channelListQuery = [SendBird queryChannelList];
    [channelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        if ([channelListQuery page] == 1) {
            [self.channels removeAllObjects];
        }
        [self.channels addObjectsFromArray:queryResult];
        
        [self.channelTableView reloadData];
        [self.refreshControl endRefreshing];
        
        [self.chattingTableViewController setIndicatorHidden:YES];
    } endBlock:^(NSError *error) {
        NSLog(@"Error");
        [self.chattingTableViewController setIndicatorHidden:YES];
    }];
}

- (void) queryChannel:(NSString *)query
{
    [self.chattingTableViewController setIndicatorHidden:NO];
    channelListQuery = [SendBird queryChannelListWithKeyword:query];
    [channelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        if ([channelListQuery page] == 1) {
            [self.channels removeAllObjects];
        }
        [self.channels addObjectsFromArray:queryResult];
        
        [self.channelTableView reloadData];
        [self.refreshControl endRefreshing];
        
        [self.chattingTableViewController setIndicatorHidden:YES];
    } endBlock:^(NSError *error) {
        [self.chattingTableViewController setIndicatorHidden:YES];
    }];
}

- (void)searchTextFieldDidChange:(UITextField *)textField
{
    if ([[textField text] length] == 0) {
        [self reloadChannels];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.channels count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelReuseIdentifier";
    
    ChannelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setModel:[self.channels objectAtIndex:indexPath.row]];
    
    if (indexPath.row == [self.channels count] - 1 && [channelListQuery hasNext]) {
        [self loadChannels];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SendBirdChannel *channel = [_channels objectAtIndex:indexPath.row];
    [self.chattingTableViewController setChannelUrl:[channel url]];
    [self.chattingTableViewController initChannelTitle];
    [self.chattingTableViewController setViewMode:kChattingViewMode];
    
    [self.chattingTableViewController startChatting];
    [self setHidden:YES];
}

#pragma mark - ChannelListQueryResultHandlerDelegate
- (void) onResult:(NSMutableArray **)queryResult
{
    if ([channelListQuery page] == 1) {
        [self.channels removeAllObjects];
    }
    [self.channels addObjectsFromArray:*queryResult];
    
    [self.channelTableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void) onError
{
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[textField text] length] > 0) {
        [self queryChannel:[textField text]];
    }
    return YES;
}

@end
