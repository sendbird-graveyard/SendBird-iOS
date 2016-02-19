//
//  ChattingTableViewController.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "ChattingTableViewController.h"
#import "MessagingTableViewController.h"

#define kMessageCellIdentifier @"MessageReuseIdentifier"
#define kFileLinkCellIdentifier @"FileLinkReuseIdentifier"
#define kSystemMessageCellIdentifier @"SystemMessageReuseIdentifier"
#define kFileMessageCellIdentifier @"FileMessageReuseIdentifier"
#define kBroadcastMessageCellIdentifier @"BroadcastMessageReuseIdentifier"
#define kStructuredMessageCellIdentifier @"StructuredMessageReuseIdentifier"

#define kActionSheetTagUrl 0
#define kActionSheetTagMyUrl 1
#define kActionSheetTagImage 2
#define kActionSheetTagMyImage 3
#define kActionSheetTagStructuredMessage 4
#define kActionSheetTagMessage 5


@interface ChattingTableViewController ()<UITableViewDataSource, UITableViewDelegate, ChatMessageInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, FileLinkTableViewCellDelegate, UIActionSheetDelegate>
@end

@implementation ChattingTableViewController {
    NSLayoutConstraint *bottomMargin;
    NSMutableArray *messageArray;
    
    MessageTableViewCell *messageSizingTableViewCell;
    FileLinkTableViewCell *fileLinkSizingTableViewCell;
    SystemMessageTableViewCell *systemMessageSizingTableViewCell;
    FileMessageTableViewCell *fileMessageSizingTableViewCell;
    BroadcastMessageTableViewCell *broadcastMessageSizingTableViewCell;
    StructuredMessageTableViewCell *structuredMessageSizingTableViewCell;
    
    NSMutableArray *imageCache;
    NSMutableDictionary *cellHeight;
    
    BOOL scrolling;
    BOOL pastMessageLoading;
    
    BOOL endDragging;
    
    int viewMode;
    
    void (^updateMessageTs)(SendBirdMessageModel *model);
    
    long long mMaxMessageTs;
    long long mMinMessageTs;
    
    SendBirdSender *messageSender;
    
    BOOL viewLoaded;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        viewMode = kChattingViewMode;
        viewLoaded = NO;
        [self clearMessageTss];
    }
    return self;
}

- (void) clearMessageTss
{
    mMaxMessageTs = LLONG_MIN;
    mMinMessageTs = LLONG_MAX;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [[[self navigationController] navigationBar] setBarTintColor:UIColorFromRGB(0x824096)];
    [[[self navigationController] navigationBar] setTranslucent:NO];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(aboutSendBird:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissModal:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    if (viewLoaded) {
        if (viewMode == kChattingViewMode) {
            [self startChatting];
        }
        else if (viewMode == kChannelListViewMode) {
            [self clickChannelListButton];
        }
    }
}

- (void) dismissModal:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) aboutSendBird:(id)sender
{
    NSString *title = @"SendBird";
    NSString *message = SENDBIRD_SAMPLE_UI_VER;
    NSString *closeButtonText = @"Close";
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SendBird" message:SENDBIRD_SAMPLE_UI_VER delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) setViewMode:(int)mode
{
    viewMode = mode;
}

- (void) initChannelTitle
{
    [self.titleLabel setText:@"Loading"];
}

- (void) updateChannelTitle
{
    [self.titleLabel setText:[NSString stringWithFormat:@"#%@", [SendBirdUtils getChannelNameFromUrl:self.channelUrl]]];
}

- (void)viewDidLoad {
    viewLoaded = YES;
    updateMessageTs = ^(SendBirdMessageModel *model) {
        if (![model hasMessageId]) {
            return;
        }
        
        mMaxMessageTs = mMaxMessageTs < [model getMessageTimestamp] ? [model getMessageTimestamp] : mMaxMessageTs;
        mMinMessageTs = mMinMessageTs > [model getMessageTimestamp] ? [model getMessageTimestamp] : mMinMessageTs;
    };
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];

    [ImageCache initImageCache];
    [[[SendBird sharedInstance] taskQueue] cancelAllOperations];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    [self.titleLabel setText:[self title]];
    [self.titleLabel sizeThatFits:CGSizeMake(200, 44)];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.navigationItem.titleView = self.titleLabel;
    
    imageCache = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.openImagePicker = NO;
    [self initViews];
    [self.channelListTableView viewDidLoad];
    
//    if (viewMode == kChattingViewMode) {
//        [self startChatting];
//    }
//    else if (viewMode == kChannelListViewMode) {
//        [self clickChannelListButton];
//    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setIndicatorHidden:(BOOL)hidden
{
    [self.indicatorView setHidden:hidden];
}

- (void) startMessagingWithUser:(NSString *)targetUserId
{
    MessagingTableViewController *viewController = [[MessagingTableViewController alloc] init];
    
    [viewController setViewMode:kMessagingViewMode];
    [viewController initChannelTitle];
    [viewController setChannelUrl:@""];
    [viewController setUserName:self.userName];
    [viewController setUserId:self.userId];
    [viewController setTargetUserId:targetUserId];

    [self.navigationController pushViewController:viewController animated:NO];
}

- (void) startChatting
{
    scrolling = NO;
    pastMessageLoading = YES;
    endDragging = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pastMessageLoading = NO;
    });
    cellHeight = [[NSMutableDictionary alloc] init];
    [self initChannelTitle];
    if (messageArray != nil) {
        [messageArray removeAllObjects];
    }
    else {
        messageArray = [[NSMutableArray alloc] init];
    }
    [self.tableView reloadData];
    
    [SendBird loginWithUserId:self.userId andUserName:self.userName];
    if (viewMode == kChattingViewMode) {
        [SendBird joinChannel:self.channelUrl];
    }
    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
        [self setIndicatorHidden:YES];
        [self.messageInputView setInputEnable:YES];
    } errorBlock:^(NSInteger code) {
        [self updateChannelTitle];
        [self setIndicatorHidden:YES];
    } channelLeftBlock:^(SendBirdChannel *channel) {
        
    } messageReceivedBlock:^(SendBirdMessage *message) {
        [self updateChannelTitle];
        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
        [self setIndicatorHidden:YES];
    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
        [self updateChannelTitle];
        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [self setIndicatorHidden:YES];
    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
        [self updateChannelTitle];
        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [self setIndicatorHidden:YES];
    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
        [self updateChannelTitle];
        [messageArray addSendBirdMessage:fileLink updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [self setIndicatorHidden:YES];
    // TODO
//    } structuredMessageReceivedBlock:^(SendBirdStructuredMessage *message) {
//        [self updateChannelTitle];
//        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
//        [self setIndicatorHidden:YES];
    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
        
    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
        
    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
        
    } allMessagingEndedBlock:^ {
        
    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
        
    } allMessagingHiddenBlock:^ {
        
    } readReceivedBlock:^(SendBirdReadStatus *status) {
        
    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
        
    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
        
    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
    } messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *messageId) {
        if (send == NO && [self.messageInputView isInputEnable]) {
            [[self.messageInputView messageTextField] setText:message];
            [self.messageInputView showSendButton];
        }
        else {
            [[self.messageInputView messageTextField] setText:@""];
            [self.messageInputView hideSendButton];
        }
    }];
    
    if (viewMode == kChattingViewMode) {
        [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:LLONG_MAX andLimit:50 resultBlock:^(NSMutableArray *queryResult) {
            mMaxMessageTs = LLONG_MIN;
            for (SendBirdMessageModel *model in queryResult) {
                [messageArray addSendBirdMessage:model updateMessageTsBlock:updateMessageTs];
                if (mMaxMessageTs < [model getMessageTimestamp]) {
                    mMaxMessageTs = [model getMessageTimestamp];
                }
            }
            [self.tableView reloadData];
            if ([messageArray count] > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messageArray count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            [SendBird connectWithMessageTs:mMaxMessageTs];
        } endBlock:^(NSError *error) {
            
        }];
    }
}

- (void)scrollToBottomWithReloading:(BOOL)reload force:(BOOL)force animated:(BOOL)animated
{
    if (reload) {
        [self.tableView reloadData];
    }
    
    if (scrolling) {
        return;
    }
    
    if (pastMessageLoading || [self isScrollBottom] || force) {
        unsigned long msgCount = [messageArray count];
        if (msgCount > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(msgCount - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    if (!self.openImagePicker) {
        [SendBird disconnect];
    }
}

- (void) initViews
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setOpaque:NO];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:UIColorFromRGB(0xf0f1f2)];
    [self.tableView setContentInset:UIEdgeInsetsMake(6,0,6,0)];
    [self.tableView setBounces:NO];
    
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:kMessageCellIdentifier];
    [self.tableView registerClass:[SystemMessageTableViewCell class] forCellReuseIdentifier:kSystemMessageCellIdentifier];
    [self.tableView registerClass:[FileLinkTableViewCell class] forCellReuseIdentifier:kFileLinkCellIdentifier];
    [self.tableView registerClass:[FileMessageTableViewCell class] forCellReuseIdentifier:kFileMessageCellIdentifier];
    [self.tableView registerClass:[BroadcastMessageTableViewCell class] forCellReuseIdentifier:kBroadcastMessageCellIdentifier];
    [self.tableView registerClass:[StructuredMessageTableViewCell class] forCellReuseIdentifier:kStructuredMessageCellIdentifier];
    [self.view addSubview:self.tableView];
    
    messageSizingTableViewCell = [[MessageTableViewCell alloc] initWithFrame:self.view.frame];
    [messageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [messageSizingTableViewCell setHidden:YES];
    [self.view addSubview:messageSizingTableViewCell];
    
    fileLinkSizingTableViewCell = [[FileLinkTableViewCell alloc] initWithFrame:self.view.frame];
    [fileLinkSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fileLinkSizingTableViewCell setHidden:YES];
    [self.view addSubview:fileLinkSizingTableViewCell];
    
    fileMessageSizingTableViewCell = [[FileMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [fileMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:fileMessageSizingTableViewCell];
    
    broadcastMessageSizingTableViewCell = [[BroadcastMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [broadcastMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [broadcastMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:broadcastMessageSizingTableViewCell];
    
    structuredMessageSizingTableViewCell = [[StructuredMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [structuredMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [structuredMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:structuredMessageSizingTableViewCell];
    
    self.messageInputView = [[ChatMessageInputView alloc] init];
    [self.messageInputView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageInputView setDelegate:self];
    [self.view addSubview:self.messageInputView];
    
    self.channelListTableView = [[ChannelListTableView alloc] init];
    [self.channelListTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.channelListTableView];
    [self.channelListTableView setHidden:YES];
    [self.channelListTableView setChattingTableViewController:self];
    
    self.indicatorView = [[IndicatorView alloc] init];
    [self.indicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView setHidden:YES];
    
    [self applyConstraints];
}

- (void) applyConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.messageInputView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    bottomMargin = [NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:bottomMargin];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelListTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelListTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.messageInputView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelListTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelListTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

- (void)keyboardWillShow:(NSNotification*)notif
{
    NSDictionary *keyboardInfo = [notif userInfo];
    NSValue *keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    [bottomMargin setConstant:-keyboardFrameEndRect.size.height];
    [self.view updateConstraints];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottomWithReloading:NO force:NO animated:NO];
    });
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [bottomMargin setConstant:0];
    [self.view updateConstraints];
    [self scrollToBottomWithReloading:NO force:NO animated:NO];
}

- (void) clearPreviousChatting
{
    [messageArray removeAllObjects];
    [self.tableView reloadData];
    scrolling = NO;
    pastMessageLoading = YES;
    endDragging = NO;
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrolling = YES;
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    scrolling = NO;
}

- (BOOL)isScrollBottom
{
    CGPoint offset = self.tableView.contentOffset;
    CGRect bounds = self.tableView.bounds;
    CGSize size = self.tableView.contentSize;
    UIEdgeInsets inset = self.tableView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (y >= (h-160)) {
        return YES;
    }
    return NO;
}

- (void) didTapOnTableView:(id)sender
{
    [self.messageInputView hideKeyboard];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0 && endDragging == YES) {
        [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:mMinMessageTs andLimit:30 resultBlock:^(NSMutableArray *queryResult) {
            for (SendBirdMessageModel *model in queryResult) {
                [messageArray addSendBirdMessage:model updateMessageTsBlock:updateMessageTs];
            }
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([queryResult count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } endBlock:^(NSError *error) {
            
        }];
        endDragging = NO;
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    endDragging = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messageArray count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier];
    }
    else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kFileLinkCellIdentifier];
    }
    else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBroadcastMessageCellIdentifier];
    }
    else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kStructuredMessageCellIdentifier];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kSystemMessageCellIdentifier];
    }
    
    if (cell == nil) {
        if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
            cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMessageCellIdentifier];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
            if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                cell = [[FileLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileLinkCellIdentifier];
                
            }
            else {
                cell = [[FileMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileMessageCellIdentifier];
            }
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]){
            cell = [[BroadcastMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBroadcastMessageCellIdentifier];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]){
            cell = [[StructuredMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStructuredMessageCellIdentifier];
        }
        else {
            cell = [[SystemMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSystemMessageCellIdentifier];
        }
    }
    else {
        if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
            [(MessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
            if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                cell = [[FileLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileLinkCellIdentifier];
            }
            else {
                cell = [[FileMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileMessageCellIdentifier];
            }
            [(FileMessageTableViewCell *)cell setModel:fileLink];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]){
            [(BroadcastMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]){
            [(StructuredMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
        }
        else {
            [(SystemMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([cell isKindOfClass:[FileLinkTableViewCell class]]) {
        [(FileLinkTableViewCell *)cell setDelegate:self];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat calculatedHeight;
    if ([cellHeight objectForKey:[NSNumber numberWithFloat:indexPath.row]] != nil && [[cellHeight objectForKey:[NSNumber numberWithFloat:indexPath.row]] floatValue] > 0) {
        long long ts = 0;
        if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
            ts = [(SendBirdMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]) {
            ts = [(SendBirdBroadcastMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
            ts = [(SendBirdFileLink *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
            ts = [(SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        
        calculatedHeight = [[cellHeight objectForKey:[NSNumber numberWithLongLong:ts]] floatValue];
    }
    else {
        long long ts = 0;
        if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
            [messageSizingTableViewCell setModel:[messageArray objectAtIndex:indexPath.row]];
            calculatedHeight = [messageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
            ts = [(SendBirdMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]) {
            [broadcastMessageSizingTableViewCell setModel:(SendBirdBroadcastMessage *)[messageArray objectAtIndex:indexPath.row]];
            calculatedHeight = [broadcastMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
            ts = [(SendBirdBroadcastMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
            [structuredMessageSizingTableViewCell setModel:(SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row]];
            calculatedHeight = [structuredMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
            ts = [(SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
            if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                [fileLinkSizingTableViewCell setModel:fileLink];
                calculatedHeight = [fileLinkSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
            }
            else {
                [fileMessageSizingTableViewCell setModel:fileLink];
                calculatedHeight = [fileMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
            }
            ts = [(SendBirdFileLink *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
        }
        else {
            calculatedHeight = 32;
        }
        [cellHeight setObject:[NSNumber numberWithFloat:calculatedHeight] forKey:[NSNumber numberWithLongLong:ts]];
    }
    
    return calculatedHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messageInputView hideKeyboard];
    
    if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
        SendBirdMessage *message = [messageArray objectAtIndex:indexPath.row];
        NSString *msgString = [message message];
        NSString *url = [SendBirdUtils getUrlFromString:msgString];
        if ([url length] > 0) {
            [self clickURL:url andUser:[message sender]];
        }
        else {
            [self clickMessage:[message sender]];
        }
    }
    else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
        SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
        if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
            [self clickImage:[[fileLink fileInfo] url] andUser:[fileLink sender]];
        }
    }
//    else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
//        SendBirdStructuredMessage *message = [messageArray objectAtIndex:indexPath.row];
//        if ([[message structuredMessageUrl] length] > 0) {
//            [self clickStructuredMessage:[message structuredMessageUrl] andUser:[message sender]];
//        }
//    }
}

- (void) clickMessage:(SendBirdSender *)sender
{
    NSString *openMessaging = [NSString stringWithFormat:@"Open Messaging with %@", [sender name]];
    messageSender = sender;
    if ([[messageSender guestId] isEqualToString:[SendBird getUserId]]) {
        return;
    }
    NSString *closeButtonText = @"Close";
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *openMessagingAction = [UIAlertAction actionWithTitle:openMessaging style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startMessagingWithUser:[messageSender guestId]];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:openMessagingAction];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        NSString *openMessaging = [NSString stringWithFormat:@"Open Messaging with %@", [sender name]];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:openMessaging, nil];
        
        [actionSheet setTag:kActionSheetTagMessage];
        [actionSheet showInView:self.view];

    }
}

- (void) clickURL:(NSString *)url andUser:(SendBirdSender *)sender
{
    messageSender = sender;
    NSString *closeButtonText = @"Close";
    NSString *openMessaging = [NSString stringWithFormat:@"Open Messaging with %@", [sender name]];
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *openLinkAction = [UIAlertAction actionWithTitle:@"Open Link in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        
        if (![[messageSender guestId] isEqualToString:[SendBird getUserId]]) {
            UIAlertAction *openMessagingAction = [UIAlertAction actionWithTitle:openMessaging style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startMessagingWithUser:[messageSender guestId]];
            }];
            [alert addAction:openMessagingAction];
        }
        
        [alert addAction:openLinkAction];
        [alert addAction:closeAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        NSString *openMessaging = [NSString stringWithFormat:@"Open Messaging with %@", [sender name]];
        
        if (![[messageSender guestId] isEqualToString:[SendBird getUserId]]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Open Link in Safari", openMessaging, nil];
            [actionSheet setTag:kActionSheetTagUrl];
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Open Link in Safari", nil];
            [actionSheet setTag:kActionSheetTagMyUrl];
            [actionSheet showInView:self.view];
        }
    }
}

- (void) clickImage:(NSString *)url andUser:(SendBirdSender *)sender
{
    messageSender = sender;
    NSString *closeButtonText = @"Close";
    NSString *openMessaging = [NSString stringWithFormat:@"Open Messaging with %@", sender.name];
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *openLinkAction = [UIAlertAction actionWithTitle:@"See Image in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        
        if (![[messageSender guestId] isEqualToString:[SendBird getUserId]]) {
            UIAlertAction *openMessagingAction = [UIAlertAction actionWithTitle:openMessaging style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startMessagingWithUser:[messageSender guestId]];
            }];
            [alert addAction:openMessagingAction];
        }
        
        [alert addAction:openLinkAction];
        [alert addAction:closeAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        if (![[messageSender guestId] isEqualToString:[SendBird getUserId]]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"See Image in Safari", openMessaging, nil];
            [actionSheet setTag:kActionSheetTagImage];
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"See Image in Safari", nil];
            [actionSheet setTag:kActionSheetTagMyImage];
            [actionSheet showInView:self.view];
        }

    }
}

//- (void) clickStructuredMessage:(NSString *)url andUser:(SendBirdSender *)sender
//{
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url
//                                                             delegate:self
//                                                    cancelButtonTitle:@"Cancel"
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@"Open", nil];
//    messageSender = sender;
//    [actionSheet setTag:kActionSheetTagStructuredMessage];
//    [actionSheet showInView:self.view];
//}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.tag == kActionSheetTagMessage) {
        if (buttonIndex == 0) {
            [self startMessagingWithUser:[messageSender guestId]];
        }
    }
    else if (actionSheet.tag == kActionSheetTagUrl) {
        if (buttonIndex == 0) {
            NSString *encodedUrl = [actionSheet.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }
        else if (buttonIndex == 1) {
            NSLog(@"User ID: %@", [messageSender guestId]);
            [self startMessagingWithUser:[messageSender guestId]];
        }
    }
    else if (actionSheet.tag == kActionSheetTagImage) {
        if (buttonIndex == 0) {
            NSString *encodedUrl = [actionSheet.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }
        else if (buttonIndex == 1) {
            NSLog(@"User ID: %@", [messageSender guestId]);
            [self startMessagingWithUser:[messageSender guestId]];
        }
    }
    else if (actionSheet.tag == kActionSheetTagMyUrl) {
        if (buttonIndex == 0) {
            NSString *encodedUrl = [actionSheet.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }
    }
    else if (actionSheet.tag == kActionSheetTagMyImage) {
        if (buttonIndex == 0) {
            NSString *encodedUrl = [actionSheet.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }
    }
    messageSender = nil;
}

#pragma mark - ChatMessageInputViewDelegate
- (void) clickSendButton:(NSString *)message
{
    [self scrollToBottomWithReloading:YES force:YES animated:NO];
    if ([message length] > 0) {
        NSString *messageId = [[NSUUID UUID] UUIDString];
        [SendBird sendMessage:message withTempId:messageId];
    }
}

- (void) clickFileAttachButton
{
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    self.openImagePicker = YES;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (void) clickChannelListButton
{
    [self clearPreviousChatting];
    if ([self.channelListTableView isHidden]) {
        [self.titleLabel setText:@"Channels"];
        [self.channelListTableView setHidden:NO];
        [self.channelListTableView reloadChannels];
        [self.messageInputView setInputEnable:NO];
        [SendBird disconnect];
    }
    else {
        [self.channelListTableView setHidden:YES];
        [self.messageInputView setInputEnable:YES];
        [SendBird connect];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __block UIImage *originalImage, *editedImage, *imageToUse;
    __block NSURL *imagePath;
    __block NSString *imageName;
    
    [self setIndicatorHidden:NO];
    [picker dismissViewControllerAnimated:YES completion:^{
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            editedImage = (UIImage *) [info objectForKey:
                                       UIImagePickerControllerEditedImage];
            originalImage = (UIImage *) [info objectForKey:
                                         UIImagePickerControllerOriginalImage];
            
            if (originalImage) {
                imageToUse = originalImage;
            } else {
                imageToUse = editedImage;
            }
            
            NSData *imageFileData = UIImagePNGRepresentation(imageToUse);
            imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            imageName = [imagePath lastPathComponent];
            
            [SendBird uploadFile:imageFileData type:@"image/jpg" hasSizeOfFile:[imageFileData length] withCustomField:@"" uploadBlock:^(SendBirdFileInfo *fileInfo, NSError *error) {
                self.openImagePicker = NO;
                [SendBird sendFile:fileInfo];
                [self setIndicatorHidden:YES];
            }];
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeVideo, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            
            [SendBird uploadFile:videoFileData type:@"video/mov" hasSizeOfFile:[videoFileData length] withCustomField:@"" uploadBlock:^(SendBirdFileInfo *fileInfo, NSError *error) {
                self.openImagePicker = NO;
                [SendBird sendFile:fileInfo];
                [self setIndicatorHidden:YES];
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        self.openImagePicker = NO;
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self scrollToBottomWithReloading:YES force:YES animated:NO];
    NSString *message = [textField text];
    if ([message length] > 0) {
        [textField setText:@""];
        NSString *messageId = [[NSUUID UUID] UUIDString];
        [SendBird sendMessage:message withTempId:messageId];
    }
    
    return YES;
}

#pragma mark - FileLinkTableViewCellDelegate
- (void)reloadCell:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}


@end