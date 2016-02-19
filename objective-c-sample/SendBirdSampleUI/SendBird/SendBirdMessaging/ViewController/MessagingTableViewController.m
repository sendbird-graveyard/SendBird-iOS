//
//  MessagingTableViewController.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingTableViewController.h"

#define kMessageCellIdentifier @"MessageReuseIdentifier"
#define kMyMessageCellIdentifier @"MyMessageReuseIdentifier"
#define kFileLinkCellIdentifier @"FileLinkReuseIdentifier"
#define kMyFileLinkCellIdentifier @"MyFileLinkReuseIdentifier"
#define kSystemMessageCellIdentifier @"SystemMessageReuseIdentifier"
#define kFileMessageCellIdentifier @"FileMessageReuseIdentifier"
#define kBroadcastMessageCellIdentifier @"BroadcastMessageReuseIdentifier"
#define kMyStructuredMessageCellIdentifier @"MyStructuredMessageReuseIdentifier"
#define kStructuredMessageCellIdentifier @"StructuredMessageReuseIdentifier"

#define kMemberCellIdentifier @"MemberReuseIdentifier"
#define kMessagingChannelCellIdentifier @"MessagingChannelReuseIdentifier"

#define kActionSheetTagUrl 0
#define kActionSheetTagImage 1
#define kActionSheetTagLobbyMember 2
#define kActionSheetTagStructuredMessage 3
#define kTypingViewHeight 36.0

@interface MessagingTableViewController ()<UITableViewDataSource, UITableViewDelegate, MessageInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
@end

@implementation MessagingTableViewController {
    NSLayoutConstraint *bottomMargin;
    NSLayoutConstraint *tableViewBottomMargin;
    NSMutableArray *messageArray;
    
    MessagingMessageTableViewCell *messageSizingTableViewCell;
    MessagingMyMessageTableViewCell *myMessageSizingTableViewCell;
    MessagingFileLinkTableViewCell *fileLinkSizingTableViewCell;
    MessagingSystemMessageTableViewCell *systemMessageSizingTableViewCell;
    MessagingFileMessageTableViewCell *fileMessageSizingTableViewCell;
    MessagingBroadcastMessageTableViewCell *broadcastMessageSizingTableViewCell;
    MessagingMyStructuredMessageTableViewCell *myStructuredMessageSizingTableViewCell;
    MessagingStructuredMessageTableViewCell *structuredMessageSizingTableViewCell;
    MessagingMyFileLinkTableViewCell *myFileLinkSizingTableViewCell;
    
    MemberTableViewCell *memberSizingTableViewCell;
    
    NSMutableArray *imageCache;
    NSMutableDictionary *cellHeight;
    
    BOOL scrolling;
    BOOL messagingChannelScrolling;
    BOOL pastMessageLoading;
    
    BOOL endDragging;
    BOOL messagingChannelEndDragging;
    
    int viewMode;
    SendBirdMemberListQuery *memberListQuery;
    NSMutableArray *membersInChannel;
    SendBirdMessagingChannelListQuery *messagingChannelListQuery;
    NSMutableArray *messagingChannels;
    
    NSMutableDictionary *readStatus;
    NSMutableDictionary *typeStatus;
    NSTimer *mTimer;
    
    __block void (^updateMessageTs)(SendBirdMessageModel *model);
    
    SendBirdUserListQuery *userListQuery;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        viewMode = kMessagingMemberViewMode;
        [self clearMessageTss];
    }
    return self;
}

- (void) clearMessageTss
{
    self.mMaxMessageTs = [SendBirdUtils getMessagingMaxMessageTs];
    self.mMinMessageTs = LLONG_MAX;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [[[self navigationController] navigationBar] setBarTintColor:UIColorFromRGB(0x533a9c)];
    [[[self navigationController] navigationBar] setTranslucent:NO];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(aboutSendBird:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissModal:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [self setNavigationButton];
}

- (void) dismissModal:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) aboutSendBird:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SendBird" message:SENDBIRD_SAMPLE_UI_VER delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (void) openMenuActionSheet:(id)sender
{
    NSString *closeButtonText = @"Cancel";
    NSString *inviteMemberText = @"Invite Member";
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *invitememberAction = [UIAlertAction actionWithTitle:inviteMemberText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openLobbyMemberListForInvite];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:invitememberAction];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:closeButtonText
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:inviteMemberText, nil];
        [actionSheet setTag:kActionSheetTagLobbyMember];
        [actionSheet showInView:self.view];
    }
}

- (void) dismissLobbyMemberListForInvite:(id)sender
{
    [self closeLobbyMemberListForInvite];
}

- (void) editMessagingChannel:(id)sender
{
    viewMode = kMessagingChannelListEditViewMode;
    [self setNavigationButton];
    [self.messagingChannelListTableView reloadData];
}

- (void) goBack:(id)sender
{
    viewMode = kMessagingChannelListViewMode;
    [self setNavigationButton];
    [self.messagingChannelListTableView reloadData];
}

- (void) leaveChannel:(id)sender
{
    NSArray *indexPaths = [self.messagingChannelListTableView indexPathsForSelectedRows];
    if ([indexPaths count] > 0) {
        for (NSIndexPath *indexPath in indexPaths) {
            NSInteger row = indexPath.row;
            SendBirdChannel *channel = [[messagingChannels objectAtIndex:row] channel];
            [SendBird endMessagingWithChannelUrl:[channel url]];
        }
    }
}

- (void) hideChannel:(id)sender
{
    NSArray *indexPaths = [self.messagingChannelListTableView indexPathsForSelectedRows];
    if ([indexPaths count] > 0) {
        for (NSIndexPath *indexPath in indexPaths) {
            NSInteger row = indexPath.row;
            SendBirdChannel *channel = [[messagingChannels objectAtIndex:row] channel];
            [SendBird hideMessagingWithChannelUrl:[channel url]];
        }
    }
}

- (void) inviteMember:(id)sender
{
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (int i = 0; i < [membersInChannel count]; i++) {
        if ([[self.channelMemberListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] isSelected]) {
            SendBirdAppUser *member = (SendBirdAppUser *)[membersInChannel objectAtIndex:i];
            [userIds addObject:[member guestId]];
        }
    }
    
    if ([userIds count] > 0) {
        if (self.currentMessagingChannel != nil && [self.currentMessagingChannel isGroupMessagingChannel]) {
            [SendBird inviteMessagingWithChannelUrl:[self.currentMessagingChannel getUrl] andUserIds:userIds];
        }
        else {
            for (SendBirdMemberInMessagingChannel *member in self.currentMessagingChannel.members) {
                if ([member.guestId isEqualToString:self.userId]) {
                    continue;
                }
                else {
                    [userIds addObject:member.guestId];
                }
            }
            [SendBird startMessagingWithUserIds:userIds];
        }

    }
    viewMode = kMessagingViewMode;
    [self setNavigationButton];
    [self.messageInputView setInputEnable:YES];
    [self.channelMemberListTableView setHidden:YES];
}

- (void) setViewMode:(int)mode
{
    viewMode = mode;
}

- (void) setReadStatus:(NSString *)userId andTimestamp:(long long)ts
{
    if (readStatus == nil) {
        readStatus = [[NSMutableDictionary alloc] init];
    }
    
    if ([readStatus objectForKey:userId] == nil) {
        [readStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
    }
    else {
        long long oldTs = [[readStatus objectForKey:userId] longLongValue];
        if (oldTs < ts) {
            [readStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
        }
    }
}


- (void) setTypeStatus:(NSString *)userId andTimestamp:(long long)ts
{
    if ([userId isEqualToString:[SendBird getUserId]]) {
        return;
    }
    
    if (typeStatus == nil) {
        typeStatus = [[NSMutableDictionary alloc] init];
    }
    
    if(ts <= 0) {
        [typeStatus removeObjectForKey:userId];
    } else {
        [typeStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
    }
}

- (void) setNavigationButton
{
    if (viewMode == kMessagingChannelListViewMode) {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] init];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissModal:)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_sendbird_btn_list_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editMessagingChannel:)];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else if (viewMode == kMessagingChannelListEditViewMode) {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] init];
        UIBarButtonItem *leaveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStylePlain target:self action:@selector(leaveChannel:)];
        [leaveButtonItem setTintColor:[UIColor whiteColor]];
        
        UIBarButtonItem *hideButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStylePlain target:self action:@selector(hideChannel:)];
        [hideButtonItem setTintColor:[UIColor whiteColor]];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
        
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:leaveButtonItem, hideButtonItem, nil];
        [leaveButtonItem setEnabled:NO];
        [hideButtonItem setEnabled:NO];
    }
    else if (viewMode == kMessagingViewMode || viewMode == kMessagingMemberViewMode) {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] init];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(openMenuActionSheet:)];
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissModal:)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    }
    else if (viewMode == kMessagingMemberForGroupChatViewMode) {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] init];
        UIBarButtonItem *inviteButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(inviteMember:)];
        [inviteButtonItem setTintColor:[UIColor whiteColor]];
        
        self.navigationItem.rightBarButtonItem = inviteButtonItem;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"_btn_close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissLobbyMemberListForInvite:)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    }
}

- (void) initChannelTitle
{
    [self setTitle:@""];
}

- (void) updateChannelTitle
{
    [self setTitle:[SendBirdUtils getChannelNameFromUrl:self.channelUrl]];
}

- (void)viewDidLoad {
    __weak typeof(self) weakSelf = self;
    
    updateMessageTs = ^(SendBirdMessageModel *model) {
        if (![model hasMessageId]) {
            return;
        }
        
        weakSelf.mMaxMessageTs = weakSelf.mMaxMessageTs < [model getMessageTimestamp] ? [model getMessageTimestamp] : weakSelf.mMaxMessageTs;
        weakSelf.mMinMessageTs = weakSelf.mMinMessageTs > [model getMessageTimestamp] ? [model getMessageTimestamp] : weakSelf.mMinMessageTs;

        [SendBirdUtils setMessagingMaxMessageTs:weakSelf.mMaxMessageTs];
    };
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [ImageCache initImageCache];
    [[[SendBird sharedInstance] taskQueue] cancelAllOperations];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
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
    membersInChannel = [[NSMutableArray alloc] init];
    messagingChannels = [[NSMutableArray alloc] init];
    [self initViews];
    
    
    if (mTimer == nil) {
        mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
    }
    
    [self startChatting];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setIndicatorHidden:(BOOL)hidden
{
    [self.indicatorView setHidden:hidden];
}

- (void)timerCallback:(NSTimer *)timer
{
    if (viewMode == kMessagingViewMode) {
        if ([self checkTypeStatus]) {
            [self showTyping];
        }
    }
}

- (BOOL) checkTypeStatus
{
    if (typeStatus != nil) {
        for (NSString *key in typeStatus) {
            if (![key isEqualToString:[SendBird getUserId]]) {
                long long lastTypedTimestamp = [[typeStatus objectForKey:key] longLongValue] / 1000;
                long long nowTimestamp = [[NSDate date] timeIntervalSince1970];
                
                if (nowTimestamp - lastTypedTimestamp > 10) {
                    [typeStatus removeObjectForKey:key];
                    return true;
                }
            }
        }
    }
    
    return false;
}

- (void) startChatting
{
    scrolling = NO;
    messagingChannelScrolling = NO;
    pastMessageLoading = YES;
    endDragging = NO;
    messagingChannelEndDragging = NO;
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
    
    [SendBird loginWithUserId:self.userId andUserName:self.userName andUserImageUrl:@"" andAccessToken:@""];
    [SendBird registerNotificationHandlerMessagingChannelUpdatedBlock:^(SendBirdMessagingChannel *channel) {
        if (viewMode == kMessagingViewMode) {
            if ([SendBird getCurrentChannel] != nil && [[SendBird getCurrentChannel] channelId] == [channel getId]) {
                [self updateMessagingChannel:channel];
            }
        }
        else {
            for (SendBirdMessagingChannel *oldChannel in messagingChannels) {
                if ([oldChannel getId] == [channel getId]) {
                    [messagingChannels removeObject:oldChannel];
                    break;
                }
            }
            [messagingChannels insertObject:channel atIndex:0];
            [self.messagingChannelListTableView reloadData];
        }
    }
    mentionUpdatedBlock:^(SendBirdMention *mention) {
        
    }];
    if (viewMode == kMessagingChannelListViewMode) {
        [self setTitle:@"Message"];
        [self.messageInputView setInputEnable:NO];
    }
    else if (viewMode == kMessagingMemberViewMode) {
        [self setTitle:@"Users"];
        [self.messageInputView setInputEnable:NO];
    }
    else if (viewMode == kMessagingMemberForGroupChatViewMode) {
        [self setTitle:@"Users"];
        [self.messageInputView setInputEnable:NO];
    }
    
    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
        [self setIndicatorHidden:YES];
        [self.messageInputView setInputEnable:YES];
        [SendBird markAsRead];
    } errorBlock:^(NSInteger code) {
        [self setIndicatorHidden:YES];
    } channelLeftBlock:^(SendBirdChannel *channel) {
        
    } messageReceivedBlock:^(SendBirdMessage *message) {
        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [SendBird markAsRead];
        [self setIndicatorHidden:YES];
    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [self setIndicatorHidden:YES];
    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [self setIndicatorHidden:YES];
    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
        [messageArray addSendBirdMessage:fileLink updateMessageTsBlock:updateMessageTs];
        [self scrollToBottomWithReloading:YES force:NO animated:NO];
        [self setIndicatorHidden:YES];
        [SendBird markAsRead];
    // TODO
//    } structuredMessageReceivedBlock:^(SendBirdStructuredMessage *message) {
//        NSLog(@"structuredMessageReceivedBlock: updateMessageTs=%lld", [message getMessageTimestamp]);
//        [messageArray addSendBirdMessage:message updateMessageTsBlock:updateMessageTs];
//        [SendBird markAsRead];
//        [self scrollToBottomWithReloading:YES force:NO animated:NO];
//        [self setIndicatorHidden:YES];
    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
        self.currentMessagingChannel = channel;
        self.channelUrl = channel.channel.url;
        
        if (readStatus != nil) {
            [readStatus removeAllObjects];
        }
        if (typeStatus != nil) {
            [typeStatus removeAllObjects];
        }
        
        [messageArray removeAllObjects];
        
        [self updateMessagingChannel:channel];
        [self.messageInputView setInputEnable:YES];
        
        [[SendBird queryMessageListInChannel:[channel getUrl]] prevWithMessageTs:LLONG_MAX andLimit:30 resultBlock:^(NSMutableArray *queryResult) {
            for (SendBirdMessageModel *model in queryResult) {
                [messageArray addSendBirdMessage:model updateMessageTsBlock:updateMessageTs];
            }
            [self.tableView reloadData];
            
            NSUInteger pos = [queryResult count] > 30 ? 30 : [queryResult count];
            if (pos > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(pos - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
            [SendBird joinChannel:[channel getUrl]];
            [SendBird connectWithMessageTs:self.mMaxMessageTs];
        } endBlock:^(NSError *error) {
            
        }];
    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
        [self updateMessagingChannel:channel];
    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
        if (viewMode == kMessagingChannelListEditViewMode) {
            viewMode = kMessagingChannelListViewMode;
            [self setNavigationButton];
            [messagingChannelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
                [messagingChannels removeAllObjects];
                [messagingChannels addObjectsFromArray:queryResult];
                [self.messagingChannelListTableView reloadData];
            } endBlock:^(NSInteger code) {
                
            }];
        }
    } allMessagingEndedBlock:^ {
        
    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
        if (viewMode == kMessagingChannelListEditViewMode) {
            viewMode = kMessagingChannelListViewMode;
            [self setNavigationButton];
            messagingChannelListQuery = [SendBird queryMessagingChannelList];
            [messagingChannelListQuery setLimit:15];
            [messagingChannelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
                [messagingChannels removeAllObjects];
                [messagingChannels addObjectsFromArray:queryResult];
                [self.messagingChannelListTableView reloadData];
            } endBlock:^(NSInteger code) {
                
            }];
        }
    } allMessagingHiddenBlock:^ {
        
    } readReceivedBlock:^(SendBirdReadStatus *status) {
        [self setReadStatus:[[status user] guestId] andTimestamp:[status timestamp]];
        [self.tableView reloadData];
    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
        [self setTypeStatus:[[status user] guestId] andTimestamp:[status timestamp]];
        [self showTyping];
    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
        [self setTypeStatus:[[status user] guestId] andTimestamp:0];
        [self showTyping];
    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
        if (sendBirdDataType == SendBirdDataTypeMessage) {
            [self scrollToBottomWithReloading:YES force:NO animated:NO];
        }
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
    
    if (viewMode == kMessagingMemberViewMode) {
        [self.channelMemberListTableView setHidden:NO];

        userListQuery = [SendBird queryUserList];
        [userListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
            for (SendBirdAppUser *user in queryResult) {
                if ([[user guestId] isEqualToString:[SendBird getUserId]]) {
                    continue;
                }
                [membersInChannel addObject:user];
            }
            [self.channelMemberListTableView reloadData];
        } endBlock:^(NSInteger code) {
            
        }];
    }
    else if (viewMode == kMessagingChannelListViewMode) {
        [self.messagingChannelListTableView setHidden:NO];
        messagingChannelListQuery = [SendBird queryMessagingChannelList];
        [messagingChannelListQuery setLimit:15];
        if ([messagingChannelListQuery hasNext]) {
            [messagingChannelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
                [messagingChannels removeAllObjects];
                [messagingChannels addObjectsFromArray:queryResult];
                [self.messagingChannelListTableView reloadData];
            } endBlock:^(NSInteger code) {
                
            }];
        }
        
        [SendBird joinChannel:@""];
        [SendBird connect];
    }
    else if (viewMode == kMessagingViewMode) {
        [self startMessagingWithUser:self.targetUserId];
    }
}

- (void)loadNextUserList
{
    [userListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        for (SendBirdAppUser *user in queryResult) {
            if ([[user guestId] isEqualToString:[SendBird getUserId]]) {
                continue;
            }
            [membersInChannel addObject:user];
        }
        [self.channelMemberListTableView reloadData];
    } endBlock:^(NSInteger code) {
        
    }];
}

- (void) updateMessagingChannel:(SendBirdMessagingChannel *)channel
{
    [self setMessagingChannelTitle:channel];
    
    if (readStatus == nil) {
        readStatus = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *newReadStatus = [[NSMutableDictionary alloc] init];
    for (SendBirdMemberInMessagingChannel *member in [channel members]) {
        NSNumber *currentStatus = [readStatus objectForKey:[member guestId]];
        if (currentStatus == nil) {
            currentStatus = [NSNumber numberWithLongLong:0];
        }
        [newReadStatus setObject:[NSNumber numberWithLongLong:MAX([currentStatus longLongValue], [channel getLastReadMillis:[member guestId]])] forKey:[member guestId]];
    }
    
    [readStatus removeAllObjects];
    for (NSString *key in newReadStatus) {
        id value = [newReadStatus objectForKey:key];
        [readStatus setObject:value forKey:key];
    }
    [self.tableView reloadData];
}


- (void)openLobbyMemberListForInvite
{
    [self setTitle:@"Invite"];
    [self.messageInputView setInputEnable:NO];
    viewMode = kMessagingMemberForGroupChatViewMode;
    [self setNavigationButton];
    [self.channelMemberListTableView setHidden:NO];

    if (membersInChannel) {
        [membersInChannel removeAllObjects];
    }
    else {
        membersInChannel = [[NSMutableArray alloc] init];
    }
    userListQuery = [SendBird queryUserList];
    [userListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
        for (SendBirdAppUser *user in queryResult) {
            if ([[user guestId] isEqualToString:[SendBird getUserId]]) {
                continue;
            }
            [membersInChannel addObject:user];
        }
        [self.channelMemberListTableView reloadData];
    } endBlock:^(NSInteger code) {
        
    }];
}

- (void)closeLobbyMemberListForInvite
{
    [self.messageInputView setInputEnable:NO];
    viewMode = kMessagingViewMode;
    [self setNavigationButton];
    [self.channelMemberListTableView setHidden:YES];
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
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    if (!self.openImagePicker) {
        [SendBird disconnect];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViews
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setOpaque:NO];
    
    // Messaging
    self.tableView = [[UITableView alloc] init];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.tableView setContentInset:UIEdgeInsetsMake(6,0,6,0)];
    [self.tableView setBounces:NO];
    
    [self.tableView registerClass:[MessagingMessageTableViewCell class] forCellReuseIdentifier:kMessageCellIdentifier];
    [self.tableView registerClass:[MessagingSystemMessageTableViewCell class] forCellReuseIdentifier:kSystemMessageCellIdentifier];
    [self.tableView registerClass:[MessagingFileLinkTableViewCell class] forCellReuseIdentifier:kFileLinkCellIdentifier];
    [self.tableView registerClass:[MessagingFileMessageTableViewCell class] forCellReuseIdentifier:kFileMessageCellIdentifier];
    [self.tableView registerClass:[MessagingBroadcastMessageTableViewCell class] forCellReuseIdentifier:kBroadcastMessageCellIdentifier];
    [self.tableView registerClass:[MessagingMyStructuredMessageTableViewCell class] forCellReuseIdentifier:kMyStructuredMessageCellIdentifier];
    [self.tableView registerClass:[MessagingMyMessageTableViewCell class] forCellReuseIdentifier:kMyMessageCellIdentifier];
    [self.tableView registerClass:[MessagingMyFileLinkTableViewCell class] forCellReuseIdentifier:kMyFileLinkCellIdentifier];
    [self.view addSubview:self.tableView];
    
    messageSizingTableViewCell = [[MessagingMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [messageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [messageSizingTableViewCell setHidden:YES];
    [self.view addSubview:messageSizingTableViewCell];
    
    myMessageSizingTableViewCell = [[MessagingMyMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [myMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [myMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:myMessageSizingTableViewCell];
    
    fileLinkSizingTableViewCell = [[MessagingFileLinkTableViewCell alloc] initWithFrame:self.view.frame];
    [fileLinkSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fileLinkSizingTableViewCell setHidden:YES];
    [self.view addSubview:fileLinkSizingTableViewCell];
    
    fileMessageSizingTableViewCell = [[MessagingFileMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [fileMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fileMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:fileMessageSizingTableViewCell];
    
    broadcastMessageSizingTableViewCell = [[MessagingBroadcastMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [broadcastMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [broadcastMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:broadcastMessageSizingTableViewCell];
    
    myStructuredMessageSizingTableViewCell = [[MessagingMyStructuredMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [myStructuredMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [myStructuredMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:myStructuredMessageSizingTableViewCell];
    
    structuredMessageSizingTableViewCell = [[MessagingStructuredMessageTableViewCell alloc] initWithFrame:self.view.frame];
    [structuredMessageSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [structuredMessageSizingTableViewCell setHidden:YES];
    [self.view addSubview:structuredMessageSizingTableViewCell];
    
    myFileLinkSizingTableViewCell = [[MessagingMyFileLinkTableViewCell alloc] initWithFrame:self.view.frame];
    [myFileLinkSizingTableViewCell setTranslatesAutoresizingMaskIntoConstraints:NO];
    [myFileLinkSizingTableViewCell setHidden:YES];
    [self.view addSubview:myFileLinkSizingTableViewCell];
    
    self.messageInputView = [[MessageInputView alloc] init];
    [self.messageInputView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageInputView setDelegate:self];
    [self.view addSubview:self.messageInputView];
    
    self.indicatorView = [[MessagingIndicatorView alloc] init];
    [self.indicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView setHidden:YES];
    
    // Member List in Channel
    self.channelMemberListTableView = [[UITableView alloc] init];
    [self.channelMemberListTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.channelMemberListTableView setDelegate:self];
    [self.channelMemberListTableView setDataSource:self];
    [self.channelMemberListTableView setHidden:YES];
    [self.channelMemberListTableView setAllowsMultipleSelection:YES];
    [self.channelMemberListTableView setSeparatorColor:[UIColor clearColor]];
    
    [self.channelMemberListTableView registerClass:[MemberTableViewCell class] forCellReuseIdentifier:kMemberCellIdentifier];
    [self.view addSubview:self.channelMemberListTableView];
    
    // Messaging Channel List
    self.messagingChannelListTableView = [[UITableView alloc] init];
    [self.messagingChannelListTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messagingChannelListTableView setDelegate:self];
    [self.messagingChannelListTableView setDataSource:self];
    [self.messagingChannelListTableView setHidden:YES];
    [self.messagingChannelListTableView setAllowsMultipleSelection:NO];
    [self.messagingChannelListTableView setSeparatorColor:[UIColor clearColor]];
    [self.messagingChannelListTableView setBounces:NO];
    
    [self.messagingChannelListTableView registerClass:[MessagingChannelTableViewCell class] forCellReuseIdentifier:kMessagingChannelCellIdentifier];
    [self.view addSubview:self.messagingChannelListTableView];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.2;
    lpgr.delegate = self;
    [self.messagingChannelListTableView addGestureRecognizer:lpgr];
    
    // Typing-now View
    self.typingNowView = [[TypingNowView alloc] init];
    [self.typingNowView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.typingNowView setHidden:YES];
    [self.view addSubview:self.typingNowView];
    
    [self applyConstraints];
}

- (void) applyConstraints
{
    // Messaging Table View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    tableViewBottomMargin = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.messageInputView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0];
    [self.view addConstraint:tableViewBottomMargin];
    
    // Message Input View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    bottomMargin = [NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeBottom
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:self.view
                                                attribute:NSLayoutAttributeBottom
                                               multiplier:1
                                                 constant:0];
    [self.view addConstraint:bottomMargin];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:44]];
    
    // Typing-now View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingNowView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.messageInputView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingNowView attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingNowView attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingNowView attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kTypingViewHeight]];
    
    // Messaging Channel List Table View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messagingChannelListTableView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messagingChannelListTableView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.messageInputView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messagingChannelListTableView attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messagingChannelListTableView attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    // Channel Member List Table View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelMemberListTableView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelMemberListTableView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.messageInputView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelMemberListTableView attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.channelMemberListTableView attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    // Indicator View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.messagingChannelListTableView];
    
    NSIndexPath *indexPath = [self.messagingChannelListTableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        SendBirdMessagingChannel *jmc = [messagingChannels objectAtIndex:indexPath.row];
        [SendBird markAsReadForChannel:[jmc getUrl]];
    } else {
        NSLog(@"gestureRecognizer.state = %ld", (long)gestureRecognizer.state);
    }
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

- (void) showTyping
{
    if ([typeStatus count] == 0) {
        [self hideTyping];
    }
    else {
        tableViewBottomMargin.constant = -kTypingViewHeight;
        [self.view updateConstraints];
        [self.typingNowView setModel:typeStatus];
        [self.typingNowView setHidden:NO];
    }
}

- (void) setMessagingChannelTitle:(SendBirdMessagingChannel *)channel
{
    SendBirdMemberInMessagingChannel *member = nil;
    if ([[channel members] count] > 0) {
        member = (SendBirdMemberInMessagingChannel *)[[channel members] objectAtIndex:0];
    }
    for (int i = 0; i < [[channel members] count]; i++) {
        if (![[[[channel members] objectAtIndex:i] guestId] isEqualToString:[SendBird getUserId]]) {
            member = [[channel members] objectAtIndex:i];
            break;
        }
    }
    
    if ([[channel members] count] > 2) {
        [self setTitle:[NSString stringWithFormat:@"Group Chat %lu", (unsigned long)[[channel members] count]]];
    }
    else {
        if (member != nil) {
            [self setTitle:[member name]];
        }
    }
}

- (void) hideTyping
{
    tableViewBottomMargin.constant = 0;
    [self.view updateConstraints];
    [self.typingNowView setHidden:YES];
}

- (void) startMessagingWithUser:(NSString *)userId
{
    [self.channelMemberListTableView setHidden:YES];
    [self.messagingChannelListTableView setHidden:YES];
    [self.tableView setHidden:NO];
    [SendBird startMessagingWithUserId:userId];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.channelMemberListTableView) {
        
    }
    else if (scrollView == self.messagingChannelListTableView) {
        messagingChannelScrolling = YES;
    }
    else {
        scrolling = YES;
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.channelMemberListTableView) {
        
    }
    else if (scrollView == self.messagingChannelListTableView) {
        messagingChannelScrolling = NO;
    }
    else {
        scrolling = NO;
    }
}

- (BOOL)isScrollBottom
{
    CGPoint offset = self.tableView.contentOffset;
    CGRect bounds = self.tableView.bounds;
    CGSize size = self.tableView.contentSize;
    UIEdgeInsets inset = self.tableView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (y >= (h-400)) {
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
    if (scrollView == self.channelMemberListTableView) {
        
    }
    else if (scrollView == self.messagingChannelListTableView) {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        if (y > h - 5 && messagingChannelEndDragging == YES) {
            [messagingChannelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
                if ([queryResult count] <= 0) {
                    return;
                }
                for (SendBirdMessagingChannel *model in queryResult) {
                    [messagingChannels addObject:model];
                }
                [self.messagingChannelListTableView reloadData];
            } endBlock:^(NSInteger code) {
                
            }];
            messagingChannelEndDragging = NO;
        }
    }
    else if (scrollView == self.tableView) {
        if (scrollView.contentOffset.y < 0 && endDragging == YES) {
            [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] prevWithMessageTs:self.mMinMessageTs andLimit:30 resultBlock:^(NSMutableArray *queryResult) {
                if ([queryResult count] <= 0) {
                    return;
                }
                for (SendBirdMessageModel *model in queryResult) {
                    [messageArray addSendBirdMessage:model updateMessageTsBlock:updateMessageTs];
                }
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[queryResult count] -1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } endBlock:^(NSError *error) {
                
            }];
            endDragging = NO;
        }
        else {
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            if (y > h - 5 && endDragging == YES) {
                NSLog(@"scroll mMaxMessageTs: %lld", self.mMaxMessageTs);
                [[SendBird queryMessageListInChannel:[SendBird getChannelUrl]] nextWithMessageTs:self.mMaxMessageTs andLimit:30 resultBlock:^(NSMutableArray *queryResult) {
                    if ([queryResult count] <= 0) {
                        return;
                    }
                    for (SendBirdMessageModel *model in queryResult) {
                        [messageArray addSendBirdMessage:model updateMessageTsBlock:updateMessageTs];
                    }
                    [self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] - [queryResult count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                } endBlock:^(NSError *error) {
                    
                }];
                endDragging = NO;
            }
        }
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.channelMemberListTableView) {
        
    }
    else if (scrollView == self.messagingChannelListTableView) {
        messagingChannelEndDragging = YES;
    }
    else {
        endDragging = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.channelMemberListTableView) {
        return 1;
    }
    else if (tableView == self.messagingChannelListTableView) {
        return 1;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.channelMemberListTableView) {
        return [membersInChannel count];
    }
    else if (tableView == self.messagingChannelListTableView) {
        return [messagingChannels count];
    }
    else {
        return [messageArray count];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.channelMemberListTableView) {
        UITableViewCell *cell = nil;
        
        if ([[membersInChannel objectAtIndex:indexPath.row] isKindOfClass:[SendBirdAppUser class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:kMemberCellIdentifier];
        }
        
        if (cell == nil) {
            if ([[membersInChannel objectAtIndex:indexPath.row] isKindOfClass:[SendBirdAppUser class]]) {
                cell = [[MemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMemberCellIdentifier];
            }
        }
        
        SendBirdAppUser *member = [membersInChannel objectAtIndex:indexPath.row];
        if (viewMode == kMessagingMemberForGroupChatViewMode) {
            [(MemberTableViewCell *)cell setModel:member withCheckMark:YES];
        }
        else {
            [(MemberTableViewCell *)cell setModel:member withCheckMark:NO];
        }
        
        if ([indexPath row] + 1 == [membersInChannel count]) {
            [self loadNextUserList];
        }
        
        return cell;
    }
    else if (tableView == self.messagingChannelListTableView) {
        UITableViewCell *cell = nil;
        if ([[messagingChannels objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessagingChannel class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:kMessagingChannelCellIdentifier];
        }
        
        if (cell == nil) {
            if ([[messagingChannels objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessagingChannel class]]) {
                cell = [[MessagingChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMessagingChannelCellIdentifier];
            }
        }
        
        SendBirdMessagingChannel *messagingChannel = [messagingChannels objectAtIndex:indexPath.row];
        if (viewMode == kMessagingChannelListEditViewMode) {
            [(MessagingChannelTableViewCell *)cell setModel:messagingChannel withCheckMark:YES];
        }
        else {
            [(MessagingChannelTableViewCell *)cell setModel:messagingChannel withCheckMark:NO];
        }
        
        return cell;
    }
    else {
        UITableViewCell *cell = nil;
        if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
            SendBirdMessage *message = (SendBirdMessage *)[messageArray objectAtIndex:indexPath.row];
            SendBirdSender *sender = [message sender];
            
            if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                cell = [tableView dequeueReusableCellWithIdentifier:kMyMessageCellIdentifier];
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier];
            }
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *message = (SendBirdFileLink *)[messageArray objectAtIndex:indexPath.row];
            SendBirdSender *sender = [message sender];
            
            if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                cell = [tableView dequeueReusableCellWithIdentifier:kMyFileLinkCellIdentifier];
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:kFileLinkCellIdentifier];
            }
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:kBroadcastMessageCellIdentifier];
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
            SendBirdStructuredMessage *message = (SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row];
            SendBirdSender *sender = [message sender];
            
            if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                cell = [tableView dequeueReusableCellWithIdentifier:kMyStructuredMessageCellIdentifier];
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:kMyStructuredMessageCellIdentifier];
            }
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:kSystemMessageCellIdentifier];
        }
        
        if (cell == nil) {
            if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
                SendBirdMessage *message = (SendBirdMessage *)[messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                    cell = [[MessagingMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyMessageCellIdentifier];
                    [(MessagingMyMessageTableViewCell *)cell setReadStatus:readStatus];
                }
                else {
                    cell = [[MessagingMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMessageCellIdentifier];
                }
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
                SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
                if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                    SendBirdSender *sender = [fileLink sender];
                    
                    if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                        cell = [[MessagingMyFileLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyFileLinkCellIdentifier];
                        [(MessagingMyFileLinkTableViewCell *)cell setReadStatus:readStatus];
                    }
                    else {
                        cell = [[MessagingFileLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileLinkCellIdentifier];
                    }
                }
                else {
                    cell = [[MessagingFileMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileMessageCellIdentifier];
                }
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]){
                cell = [[MessagingBroadcastMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBroadcastMessageCellIdentifier];
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
                SendBirdStructuredMessage *message = (SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                    cell = [[MessagingMyStructuredMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyStructuredMessageCellIdentifier];
                    [(MessagingMyStructuredMessageTableViewCell *)cell setReadStatus:readStatus];
                }
                else {
                    cell = [[MessagingStructuredMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStructuredMessageCellIdentifier];
                }
            }
            else {
                cell = [[MessagingSystemMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSystemMessageCellIdentifier];
            }
        }
        else {
            if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
                SendBirdMessage *message = (SendBirdMessage *)[messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                    [(MessagingMyMessageTableViewCell *)cell setReadStatus:readStatus];
                    [(MessagingMyMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
                }
                else {
                    [(MessagingMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
                }
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
                SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
                if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                    SendBirdSender *sender = [fileLink sender];
                    
                    if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                        cell = [[MessagingMyFileLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyFileLinkCellIdentifier];
                        [(MessagingMyFileLinkTableViewCell *)cell setReadStatus:readStatus];
                        [(MessagingMyFileLinkTableViewCell *)cell setModel:fileLink];
                    }
                    else {
                        cell = [[MessagingFileLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileLinkCellIdentifier];
                        [(MessagingFileMessageTableViewCell *)cell setModel:fileLink];
                    }
                }
                else {
                    cell = [[MessagingFileMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFileMessageCellIdentifier];
                    [(MessagingFileMessageTableViewCell *)cell setModel:fileLink];
                }
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]){
                [(MessagingBroadcastMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
                SendBirdStructuredMessage *message = (SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                    cell = [[MessagingMyStructuredMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMyStructuredMessageCellIdentifier];
                    [(MessagingMyStructuredMessageTableViewCell *)cell setReadStatus:readStatus];
                    [(MessagingMyStructuredMessageTableViewCell *)cell setModel:message];
                }
                else {
                    cell = [[MessagingStructuredMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kStructuredMessageCellIdentifier];
                    [(MessagingStructuredMessageTableViewCell *)cell setModel:message];
                }
            }
            else {
                [(MessagingSystemMessageTableViewCell *)cell setModel:[messageArray objectAtIndex:indexPath.row]];
            }
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.channelMemberListTableView) {
        return 60;
    }
    else if (tableView == self.messagingChannelListTableView) {
        return 60;
    }
    else {
        CGFloat calculatedHeight;
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
        
        if ([cellHeight objectForKey:[NSNumber numberWithLongLong:ts]] != nil && [[cellHeight objectForKey:[NSNumber numberWithLongLong:ts]] floatValue] > 0) {
            calculatedHeight = [[cellHeight objectForKey:[NSNumber numberWithLongLong:ts]] floatValue];
        }
        else {
            long long ts = 0;
            
            if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
                SendBirdMessage *message = (SendBirdMessage *)[messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                    [myMessageSizingTableViewCell setModel:[messageArray objectAtIndex:indexPath.row]];
                    calculatedHeight = [myMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                }
                else {
                    [messageSizingTableViewCell setModel:[messageArray objectAtIndex:indexPath.row]];
                    calculatedHeight = [messageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                }
                
                ts = [(SendBirdMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdBroadcastMessage class]]) {
                [broadcastMessageSizingTableViewCell setModel:(SendBirdBroadcastMessage *)[messageArray objectAtIndex:indexPath.row]];
                calculatedHeight = [broadcastMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                ts = [(SendBirdBroadcastMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
                SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
                if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                    SendBirdSender *sender = [fileLink sender];
                    
                    if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                        [myFileLinkSizingTableViewCell setModel:fileLink];
                        calculatedHeight = [myFileLinkSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                    }
                    else {
                        [fileLinkSizingTableViewCell setModel:fileLink];
                        calculatedHeight = [fileLinkSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                    }
                }
                else {
                    [fileMessageSizingTableViewCell setModel:fileLink];
                    calculatedHeight = [fileMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                }
                ts = [(SendBirdFileLink *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
                SendBirdStructuredMessage *message = [messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if ([[sender guestId] isEqualToString:[SendBird getUserId]]) {
                    [myStructuredMessageSizingTableViewCell setModel:message];
                    calculatedHeight = [myStructuredMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                }
                else {
                    [myStructuredMessageSizingTableViewCell setModel:message];
                    calculatedHeight = [myStructuredMessageSizingTableViewCell getHeightOfViewCell:self.view.frame.size.width];
                }
                ts = [(SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row] getMessageTimestamp];
            }
            else {
                calculatedHeight = 32;
            }
            [cellHeight setObject:[NSNumber numberWithFloat:calculatedHeight] forKey:[NSNumber numberWithLongLong:ts]];
        }
        
        SendBirdSender *prevSender = nil;
        BOOL contMsg = NO;
        if (indexPath.row > 0) {
            if ([[messageArray objectAtIndex:indexPath.row - 1] isKindOfClass:[SendBirdMessage class]]) {
                prevSender = [(SendBirdMessage *)[messageArray objectAtIndex:indexPath.row - 1] sender];
            }
            else if ([[messageArray objectAtIndex:indexPath.row - 1] isKindOfClass:[SendBirdFileLink class]]) {
                prevSender = [(SendBirdFileLink *)[messageArray objectAtIndex:indexPath.row - 1] sender];
            }
            else if ([[messageArray objectAtIndex:indexPath.row - 1] isKindOfClass:[SendBirdStructuredMessage class]]) {
                prevSender = [(SendBirdStructuredMessage *)[messageArray objectAtIndex:indexPath.row - 1] sender];
            }
            
            if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
                SendBirdMessage *message = (SendBirdMessage *)[messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                
                if (prevSender != nil) {
                    if ([sender.guestId isEqualToString:prevSender.guestId]) {
                        contMsg = YES;
                    }
                }
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
                SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [fileLink sender];
                if (prevSender != nil) {
                    if ([sender.guestId isEqualToString:prevSender.guestId]) {
                        contMsg = YES;
                    }
                }
            }
            else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
                SendBirdStructuredMessage *message = [messageArray objectAtIndex:indexPath.row];
                SendBirdSender *sender = [message sender];
                if (prevSender != nil) {
                    if ([sender.guestId isEqualToString:prevSender.guestId]) {
                        contMsg = YES;
                    }
                }
            }
        }
        
        if (contMsg) {
            calculatedHeight = calculatedHeight - 10;
        }
        
        return calculatedHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.channelMemberListTableView) {
        if (viewMode == kMessagingMemberForGroupChatViewMode) {
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:YES];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
                [item setEnabled:YES];
            }
        }
        else {
            [tableView setHidden:YES];
            [self.tableView setHidden:NO];
            SendBirdAppUser *member = (SendBirdAppUser *)[membersInChannel objectAtIndex:indexPath.row];
            [SendBird startMessagingWithUserId:[member guestId]];
        }
    }
    else if (tableView == self.messagingChannelListTableView) {
        if (viewMode == kMessagingChannelListEditViewMode) {
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:YES];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
                [item setEnabled:YES];
            }
        }
        else {
            [tableView setHidden:YES];
            [self.tableView setHidden:NO];
            SendBirdMessagingChannel *messagingChannel = [messagingChannels objectAtIndex:indexPath.row];
            SendBirdChannel *channel = [messagingChannel channel];
            [SendBird joinMessagingWithChannelUrl:[channel url]];
            viewMode = kMessagingViewMode;
            [self setNavigationButton];
        }
    }
    else {
        [self.messageInputView hideKeyboard];
        
        if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdMessage class]]) {
            SendBirdMessage *message = [messageArray objectAtIndex:indexPath.row];
            NSString *msgString = [message message];
            NSString *url = [SendBirdUtils getUrlFromString:msgString];
            if ([url length] > 0) {
                [self clickURL:[NSURL URLWithString:url]];
            }
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdFileLink class]]) {
            SendBirdFileLink *fileLink = [messageArray objectAtIndex:indexPath.row];
            if ([[[fileLink fileInfo] type] hasPrefix:@"image"]) {
                [self clickImage:[NSURL URLWithString:[[fileLink fileInfo] url]]];
            }
        }
        else if ([[messageArray objectAtIndex:indexPath.row] isKindOfClass:[SendBirdStructuredMessage class]]) {
            SendBirdStructuredMessage *message = [messageArray objectAtIndex:indexPath.row];
            NSLog(@"URL: %@", [message structuredMessageUrl]);
            if ([[message structuredMessageUrl] length] > 0) {
                [self clickStructuredMessage:[message structuredMessageUrl]];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.messagingChannelListTableView) {
        if (viewMode == kMessagingChannelListEditViewMode || viewMode == kMessagingMemberForGroupChatViewMode) {
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
            if ([[tableView indexPathsForSelectedRows] count] > 0){
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
                for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
                    [item setEnabled:YES];
                }
            }
            else {
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
                    [item setEnabled:NO];
                }
            }
        }
    }
    else if (tableView == self.channelMemberListTableView) {
        if (viewMode == kMessagingMemberForGroupChatViewMode) {
            [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
        }
    }
}

- (void) clickURL:(NSURL *)url
{
    NSString *closeButtonText = @"Cancel";
    NSString *openLinkText = @"Open Link in Safari";
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *openLinkAction = [UIAlertAction actionWithTitle:openLinkText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *encodedUrl = [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:openLinkAction];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[url absoluteString]
                                                                 delegate:self
                                                        cancelButtonTitle:closeButtonText
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:openLinkText, nil];
        [actionSheet setTag:kActionSheetTagUrl];
        [actionSheet showInView:self.view];
    }
}

- (void) clickImage:(NSURL *)url
{
    NSString *closeButtonText = @"Cancel";
    NSString *seeImageText = @"See Image in Safari";
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *seeImageAction = [UIAlertAction actionWithTitle:seeImageText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *encodedUrl = [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:closeButtonText style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:seeImageAction];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[url absoluteString]
                                                                 delegate:self
                                                        cancelButtonTitle:closeButtonText
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:seeImageText, nil];
        [actionSheet setTag:kActionSheetTagImage];
        [actionSheet showInView:self.view];
    }
}

- (void) clickStructuredMessage:(NSString *)url
{
    NSLog(@"URL: %@", url);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open", nil];
    [actionSheet setTag:kActionSheetTagStructuredMessage];
    [actionSheet showInView:self.view];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetTagUrl || actionSheet.tag == kActionSheetTagImage || actionSheet.tag == kActionSheetTagStructuredMessage)
    {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        NSString *encodedUrl = [actionSheet.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrl]];
    }
    else if (actionSheet.tag == kActionSheetTagLobbyMember) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        [self openLobbyMemberListForInvite];
    }
}

#pragma mark - MessageInputViewDelegate
- (void) clickSendButton:(NSString *)message
{
    [self scrollToBottomWithReloading:NO force:YES animated:NO];
    if ([message length] > 0) {
        NSString *messageId = [[NSUUID UUID] UUIDString];
        [SendBird sendMessage:message withTempId:messageId];
    }
}

- (void) clickFileAttachButton
{
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    self.openImagePicker = YES;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (void) clickChannelListButton
{
    [self clearPreviousChatting];
    if ([self.messagingChannelListTableView isHidden]) {
        [self.messagingChannelListTableView setHidden:NO];
        [self.messageInputView setInputEnable:NO];
        [self.messagingChannelListTableView setHidden:NO];
        messagingChannelListQuery = [SendBird queryMessagingChannelList];
        [messagingChannelListQuery setLimit:15];
        [messagingChannelListQuery nextWithResultBlock:^(NSMutableArray *queryResult) {
            [messagingChannels removeAllObjects];
            [messagingChannels addObjectsFromArray:queryResult];
            [self.messagingChannelListTableView reloadData];
        } endBlock:^(NSInteger code) {
            
        }];
    }
    else {
        [self.messagingChannelListTableView setHidden:YES];
        [self.messageInputView setInputEnable:YES];
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
    [self scrollToBottomWithReloading:NO force:YES animated:NO];
    NSString *message = [textField text];
    if ([message length] > 0) {
        [SendBird typeEnd];
        [textField setText:@""];
        NSString *messageId = [[NSUUID UUID] UUIDString];
        [SendBird sendMessage:message withTempId:messageId];
    }
    
    return YES;
}

#pragma mark - MessagingFileLinkTableViewCellDelegate
- (void)reloadCell:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

@end