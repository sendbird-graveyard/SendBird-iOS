//
//  MessagingViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MessagingViewController.h"

@interface MessagingViewController ()

@property (strong, nonnull) NSMutableDictionary *avatars;
@property (strong, nonnull) NSMutableDictionary *users;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) NSMutableArray<JSQSBMessage *> *messages;

@property (atomic) long long lastMessageTimestamp;
@property (atomic) long long firstMessageTimestamp;

@property (atomic) BOOL isLoading;
@property (atomic) BOOL hasPrev;

@property (atomic) BOOL openImagePicker;
@property (strong, nonatomic) NSArray<NSString *> *userIds;
@property (strong) NSString *messagingChannelUrl;

@property (atomic) int messagingStartType;
@property (strong, nonatomic) SendBirdMessagingChannel *messagingChannel;

@property (strong) NSMutableDictionary *readStatus;
@property (strong) NSMutableDictionary *typeStatus;
@property (strong) NSTimer *timer;

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isLoading = NO;
    self.hasPrev = YES;
    
    self.openImagePicker = NO;
    
    self.avatars = [[NSMutableDictionary alloc] init];
    self.users = [[NSMutableDictionary alloc] init];
    self.messages = [[NSMutableArray alloc] init];
    
    self.lastMessageTimestamp = LLONG_MIN;
    self.firstMessageTimestamp = LLONG_MAX;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);
    
    self.showLoadEarlierMessagesHeader = NO;
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    [self.collectionView setBounces:NO];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
    }
    
    [self startSendBird];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closePressed:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [SendBird disconnect];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) setReadStatus:(NSString *)userId andTimestamp:(long long)ts
{
    if (self.readStatus == nil) {
        self.readStatus = [[NSMutableDictionary alloc] init];
    }
    
    if ([self.readStatus objectForKey:userId] == nil) {
        [self.readStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
    }
    else {
        long long oldTs = [[self.readStatus objectForKey:userId] longLongValue];
        if (oldTs < ts) {
            [self.readStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
        }
    }
}

- (void) setTypeStatus:(NSString *)userId andTimestamp:(long long)ts
{
    if ([userId isEqualToString:[SendBird getUserId]]) {
        return;
    }
    
    if (self.typeStatus == nil) {
        self.typeStatus = [[NSMutableDictionary alloc] init];
    }
    
    if(ts <= 0) {
        [self.typeStatus removeObjectForKey:userId];
    } else {
        [self.typeStatus setObject:[NSNumber numberWithLongLong:ts] forKey:userId];
    }
}

- (void)timerCallback:(NSTimer *)timer
{
    if ([self checkTypeStatus]) {
        [self showTyping];
    }
}

- (BOOL) checkTypeStatus
{
    if (self.typeStatus != nil) {
        for (NSString *key in self.typeStatus) {
            if (![key isEqualToString:[SendBird getUserId]]) {
                long long lastTypedTimestamp = [[self.typeStatus objectForKey:key] longLongValue] / 1000;
                long long nowTimestamp = [[NSDate date] timeIntervalSince1970];
                
                if (nowTimestamp - lastTypedTimestamp > 10) {
                    [self.typeStatus removeObjectForKey:key];
                    return true;
                }
            }
        }
    }
    
    return false;
}

- (void) updateMessagingChannel:(SendBirdMessagingChannel *)channel
{
    if (self.readStatus == nil) {
        self.readStatus = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *newReadStatus = [[NSMutableDictionary alloc] init];
    for (SendBirdMemberInMessagingChannel *member in [channel members]) {
        NSNumber *currentStatus = [self.readStatus objectForKey:[member guestId]];
        if (currentStatus == nil) {
            currentStatus = [NSNumber numberWithLongLong:0];
        }
        [newReadStatus setObject:[NSNumber numberWithLongLong:MAX([currentStatus longLongValue], [channel getLastReadMillis:[member guestId]])] forKey:[member guestId]];
    }
    
    [self.readStatus removeAllObjects];
    for (NSString *key in newReadStatus) {
        id value = [newReadStatus objectForKey:key];
        [self.readStatus setObject:value forKey:key];
    }
    [self.collectionView reloadData];
}

- (void) showTyping
{
    if ([self.typeStatus count] == 0) {
        [self hideTyping];
    }
    else {
        self.showTypingIndicator = YES;
    }
}

- (void) hideTyping
{
    self.showTypingIndicator = NO;
}

- (void)startSendBird {
    [SendBird registerNotificationHandlerMessagingChannelUpdatedBlock:^(SendBirdMessagingChannel *channel) {
        if ([SendBird getCurrentChannel] != nil && [[SendBird getCurrentChannel] channelId] == [channel getId]) {
            [self updateMessagingChannel:channel];
        }
    }
    mentionUpdatedBlock:^(SendBirdMention *mention) {

    }];
    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
        [SendBird markAsRead];
    } errorBlock:^(NSInteger code) {
        
    } channelLeftBlock:^(SendBirdChannel *channel) {
        
    } messageReceivedBlock:^(SendBirdMessage *message) {
        [SendBird markAsRead];
        if ([message getMessageTimestamp] > self.lastMessageTimestamp) {
            self.lastMessageTimestamp = [message getMessageTimestamp];
        }
        
        if ([message getMessageTimestamp] < self.firstMessageTimestamp) {
            self.firstMessageTimestamp = [message getMessageTimestamp];
        }
        
        JSQSBMessage *jsqsbmsg = nil;
        
        NSString *senderId = [[((SendBirdMessage *)message) sender] guestId];
        NSString *senderImage = [[((SendBirdMessage *)message) sender] imageUrl];
        NSString *senderName = [[((SendBirdMessage *)message) sender] name];
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[message getMessageTimestamp] / 1000];
        NSString *messageText = [((SendBirdMessage *)message) message];
        
        UIImage *placeholderImage = [JSQMessagesAvatarImageFactory circularAvatarPlaceholderImage:@"TC"
                                                                                  backgroundColor:[UIColor lightGrayColor]
                                                                                        textColor:[UIColor darkGrayColor]
                                                                                             font:[UIFont systemFontOfSize:13.0f]
                                                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImageURL:senderImage
                                                                                 highlightedImageURL:senderImage
                                                                                    placeholderImage:placeholderImage
                                                                                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        [self.avatars setObject:avatarImage forKey:senderId];
        [self.users setObject:senderName forKey:senderId];
        
        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate text:messageText];
        jsqsbmsg.message = message;
        
        [self.messages addObject:jsqsbmsg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:NO];
        });
    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
        
    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
        
    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
        [SendBird markAsRead];
        if ([fileLink getMessageTimestamp] > self.lastMessageTimestamp) {
            self.lastMessageTimestamp = [fileLink getMessageTimestamp];
        }
        
        if ([fileLink getMessageTimestamp] < self.firstMessageTimestamp) {
            self.firstMessageTimestamp = [fileLink getMessageTimestamp];
        }
        
        JSQSBMessage *jsqsbmsg = nil;
        
        NSString *senderId = [[((SendBirdFileLink *)fileLink) sender] guestId];
        NSString *senderImage = [[((SendBirdFileLink *)fileLink) sender] imageUrl];
        NSString *senderName = [[((SendBirdFileLink *)fileLink) sender] name];
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[fileLink getMessageTimestamp] / 1000];
        NSString *url = [[((SendBirdFileLink *)fileLink) fileInfo] url];
        
        UIImage *placeholderImage = [JSQMessagesAvatarImageFactory circularAvatarPlaceholderImage:@"TC"
                                                                                  backgroundColor:[UIColor lightGrayColor]
                                                                                        textColor:[UIColor darkGrayColor]
                                                                                             font:[UIFont systemFontOfSize:13.0f]
                                                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImageURL:senderImage
                                                                                 highlightedImageURL:senderImage
                                                                                    placeholderImage:placeholderImage
                                                                                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        [self.avatars setObject:avatarImage forKey:senderId];
        [self.users setObject:senderName forKey:senderId];
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageURL:url];
        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:photoItem];
        
        [self.messages addObject:jsqsbmsg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:NO];
        });
    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
        if (self.readStatus != nil) {
            [self.readStatus removeAllObjects];
        }
        
        if (self.typeStatus != nil) {
            [self.typeStatus removeAllObjects];
        }
        
        [self updateMessagingChannel:channel];
        self.messagingChannel = channel;
        [self loadMessages:LLONG_MAX initial:YES];
    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
        self.messagingChannel = channel;
        [self loadMessages:LLONG_MAX initial:YES];
    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
        
    } allMessagingEndedBlock:^{
        
    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
        
    } allMessagingHiddenBlock:^{
        
    } readReceivedBlock:^(SendBirdReadStatus *status) {
        [self setReadStatus:[[status user] guestId] andTimestamp:[status timestamp]];
        [self.collectionView reloadData];
    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
        [self setTypeStatus:[[status user] guestId] andTimestamp:[status timestamp]];
        [self showTyping];
    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
        [self setTypeStatus:[[status user] guestId] andTimestamp:0];
        [self showTyping];
    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
        
    } messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *tempId) {
        
    } mutedMessagesReceivedBlock:^(SendBirdMessage *message) {
        
    } mutedFileReceivedBlock:^(SendBirdFileLink *message) {
        
    }];
    
    if (self.messagingStartType == MESSAGING_START_WITH_CHANNELURL) {
        [SendBird joinMessagingWithChannelUrl:[self.messagingChannel getUrl]];
    }
    else if (self.messagingStartType == MESSAGING_START_WITH_USERIDS) {
        [SendBird startMessagingWithUserIds:self.userIds];
    }
}

- (void)setChannel:(SendBirdMessagingChannel *)aMessagingChannel
{
    self.messagingChannel = aMessagingChannel;
    self.messagingStartType = MESSAGING_START_WITH_CHANNELURL;
}

- (void)loadMessages:(long long)ts initial:(BOOL)initial {
    if (self.isLoading) {
        return;
    }
    
    if (!self.hasPrev) {
        return;
    }
    
    self.isLoading = YES;
    
    [[SendBird queryMessageListInChannel:[self.messagingChannel getUrl]] prevWithMessageTs:ts andLimit:50 resultBlock:^(NSMutableArray *queryResult) {
        if ([queryResult count] == 0) {
            self.hasPrev = NO;
        }
        int msgCount = 0;
        for (SendBirdMessageModel *item in queryResult) {
            JSQSBMessage *jsqsbmsg = nil;
            
            if ([item isKindOfClass:[SendBirdMessage class]]) {
                NSString *senderId = [[((SendBirdMessage *)item) sender] guestId];
                NSString *senderImage = [[((SendBirdMessage *)item) sender] imageUrl];
                NSString *senderName = [[((SendBirdMessage *)item) sender] name];
                NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[item getMessageTimestamp] / 1000];
                NSString *message = [((SendBirdMessage *)item) message];
                
                NSString *initialName = @"";
                if ([senderName length] > 1) {
                    initialName = [[senderName substringWithRange:NSMakeRange(0, 2)] uppercaseString];
                }
                else if ([senderName length] > 0) {
                    initialName = [[senderName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                }
                
                UIImage *placeholderImage = [JSQMessagesAvatarImageFactory circularAvatarPlaceholderImage:initialName
                                                                                          backgroundColor:[UIColor lightGrayColor]
                                                                                                textColor:[UIColor darkGrayColor]
                                                                                                     font:[UIFont systemFontOfSize:13.0f]
                                                                                                 diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImageURL:senderImage
                                                                                         highlightedImageURL:nil
                                                                                            placeholderImage:placeholderImage
                                                                                                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                
                [self.avatars setObject:avatarImage forKey:senderId];
                [self.users setObject:senderName forKey:senderId];
                
                jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate text:message];
                jsqsbmsg.message = item;
                msgCount += 1;
            }
            else if ([item isKindOfClass:[SendBirdFileLink class]]) {
                NSString *senderId = [[((SendBirdFileLink *)item) sender] guestId];
                NSString *senderImage = [[((SendBirdFileLink *)item) sender] imageUrl];
                NSString *senderName = [[((SendBirdFileLink *)item) sender] name];
                NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[item getMessageTimestamp] / 1000];
                NSString *url = [[((SendBirdFileLink *)item) fileInfo] url];
                
                NSString *initialName = @"";
                if ([senderName length] > 1) {
                    initialName = [[senderName substringWithRange:NSMakeRange(0, 2)] uppercaseString];
                }
                else if ([senderName length] > 0) {
                    initialName = [[senderName substringWithRange:NSMakeRange(0, 1)] uppercaseString];
                }
                
                UIImage *placeholderImage = [JSQMessagesAvatarImageFactory circularAvatarPlaceholderImage:initialName
                                                                                          backgroundColor:[UIColor lightGrayColor]
                                                                                                textColor:[UIColor darkGrayColor]
                                                                                                     font:[UIFont systemFontOfSize:13.0f]
                                                                                                 diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImageURL:senderImage
                                                                                         highlightedImageURL:nil
                                                                                            placeholderImage:placeholderImage
                                                                                                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                
                [self.avatars setObject:avatarImage forKey:senderId];
                [self.users setObject:senderName forKey:senderId];
                
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageURL:url];
                jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:photoItem];
                msgCount += 1;
            }
            
            if ([item getMessageTimestamp] > self.lastMessageTimestamp) {
                self.lastMessageTimestamp = [item getMessageTimestamp];
            }
            
            if ([item getMessageTimestamp] < self.firstMessageTimestamp) {
                self.firstMessageTimestamp = [item getMessageTimestamp];
            }
            
            if (jsqsbmsg != nil) {
                if ([item isPast]) {
                    [self.messages insertObject:jsqsbmsg atIndex:0];
                }
                else {
                    [self.messages addObject:jsqsbmsg];
                }
            }
        }
        [self.collectionView reloadData];
        if (initial) {
            [self scrollToBottomAnimated:NO];
            [SendBird markAsReadForChannel:[self.messagingChannel getUrl]];
            [SendBird joinChannel:[self.messagingChannel getUrl]];
            [SendBird connectWithMessageTs:self.lastMessageTimestamp];
        }
        else {
            unsigned long totalMsgCount = [self.collectionView numberOfItemsInSection:0];
            if (msgCount - 1 > 0 && totalMsgCount > 0) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(msgCount - 1) inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionTop
                                                    animated:NO];
            }
        }
        
        self.isLoading = NO;
    } endBlock:^(NSError *error) {
        self.isLoading = NO;
    }];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQSBMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQSBMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    //    if ([message.senderId isEqualToString:self.senderId]) {
    //        if (![NSUserDefaults outgoingAvatarSetting]) {
    //            return nil;
    //        }
    //    }
    //    else {
    //        if (![NSUserDefaults incomingAvatarSetting]) {
    //            return nil;
    //        }
    //    }
    
    
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQSBMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQSBMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQSBMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQSBMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    if ([msg.senderId isEqualToString:[SendBird getUserId]]) {
        int unreadCount = 0;
        if (self.readStatus != nil) {
            for (NSString *key in self.readStatus) {
                if (![key isEqualToString:[SendBird getUserId]]) {
                    long long readTime = [[self.readStatus objectForKey:key] longLongValue];
                    if ([[msg message] getMessageTimestamp] > readTime) {
                        unreadCount = unreadCount + 1;
                    }
                }
            }
        }
        [cell setUnreadCount:unreadCount];
    }
    
    if (indexPath.row == 0) {
        [self loadMessages:self.firstMessageTimestamp initial:NO];
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQSBMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQSBMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    //    if ([UIPasteboard generalPasteboard].image) {
    //        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
    //        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
    //        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
    //                                                 senderDisplayName:self.senderDisplayName
    //                                                              date:[NSDate date]
    //                                                             media:item];
    //        [self.demoData.messages addObject:message];
    //        [self finishSendingMessage];
    //        return NO;
    //    }
    return YES;
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if ([text length] > 0) {
        [SendBird sendMessage:text];
        [[[self.inputToolbar contentView] textView] setText:@""];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    self.openImagePicker = YES;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __block UIImage *originalImage, *editedImage, *imageToUse;
    __block NSURL *imagePath;
    __block NSString *imageName;
    
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
            
            imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            imageName = [imagePath lastPathComponent];
            
            CGFloat newWidth = 0;
            CGFloat newHeight = 0;
            if (imageToUse.size.width > imageToUse.size.height) {
                newWidth = 450;
                newHeight = newWidth * imageToUse.size.height / imageToUse.size.width;
            }
            else {
                newHeight = 450;
                newWidth = newHeight * imageToUse.size.width / imageToUse.size.height;
            }
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
            [imageToUse drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *imageFileData = UIImagePNGRepresentation(newImage);
            
            [SendBird uploadFile:imageFileData filename:@"asset.png" type:@"image/png" hasSizeOfFile:[imageFileData length] withCustomField:@"" uploadBlock:^(SendBirdFileInfo *fileInfo, NSError *error) {
                self.openImagePicker = NO;
                [SendBird sendFile:fileInfo];
            }];
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeVideo, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            
            [SendBird uploadFile:videoFileData filename:@"asset.mov" type:@"video/mov" hasSizeOfFile:[videoFileData length] withCustomField:@"" uploadBlock:^(SendBirdFileInfo *fileInfo, NSError *error) {
                self.openImagePicker = NO;
                [SendBird sendFile:fileInfo];
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

- (void)inviteUsers:(NSArray *)aUserIds
{
    self.userIds = aUserIds;
    self.messagingStartType = MESSAGING_START_WITH_USERIDS;
}

- (void)joinMessagingChannel:(NSString *)aChannelUrl
{
    self.messagingChannelUrl = aChannelUrl;
    self.messagingStartType = MESSAGING_START_WITH_CHANNELURL;
}

@end
