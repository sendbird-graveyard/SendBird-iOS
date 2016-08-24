//
//  OpenChatViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "OpenChatViewController.h"
#import "ParticipantListViewController.h"
#import "BlockedUserListViewController.h"

@interface OpenChatViewController ()

@property (strong, nonnull) NSMutableDictionary *avatars;
@property (strong, nonnull) NSMutableDictionary *users;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *neutralBubbleImageData;
@property (strong, nonatomic) NSMutableArray<JSQSBMessage *> *messages;

@property (atomic) long long lastMessageTimestamp;
@property (atomic) long long firstMessageTimestamp;

@property (atomic) BOOL isLoading;
@property (atomic) BOOL hasPrev;

@property (strong, nonatomic) SBDPreviousMessageListQuery *previousMessageQuery;
@property (strong, nonnull) NSString *delegateIndetifier;

@end

@implementation OpenChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isLoading = NO;
    self.hasPrev = YES;
    
    self.avatars = [[NSMutableDictionary alloc] init];
    self.users = [[NSMutableDictionary alloc] init];
    self.messages = [[NSMutableArray alloc] init];
    
    self.lastMessageTimestamp = LLONG_MIN;
    self.firstMessageTimestamp = LLONG_MAX;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPressed:)];
    
    self.showLoadEarlierMessagesHeader = NO;
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    [self.collectionView setBounces:NO];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessagesBubbleImageFactory *neutralBubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessImage] capInsets:UIEdgeInsetsZero];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.neutralBubbleImageData = [neutralBubbleFactory neutralMessagesBubbleImageWithColor:[UIColor jsq_messageNeutralBubbleColor]];
    
    self.delegateIndetifier = self.description;
    
    [SBDMain addChannelDelegate:self identifier:self.delegateIndetifier];
    [SBDMain addConnectionDelegate:self identifier:self.delegateIndetifier];
    
    [self startSendBird];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [SBDMain removeChannelDelegateForIdentifier:self.delegateIndetifier];
        [SBDMain removeConnectionDelegateForIdentifier:self.delegateIndetifier];
        
        [self.channel exitChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            
        }];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionPressed:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *seeParticipantAction = [UIAlertAction actionWithTitle:@"See participant list" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ParticipantListViewController *vc = [[ParticipantListViewController alloc] init];
        vc.currentChannel = self.channel;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    UIAlertAction *seeBlockedUserListAction = [UIAlertAction actionWithTitle:@"See blocked user list" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BlockedUserListViewController *vc = [[BlockedUserListViewController alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"Exit from this channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.channel exitChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }];
    
    [alert addAction:closeAction];
    [alert addAction:seeParticipantAction];
    [alert addAction:seeBlockedUserListAction];
    [alert addAction:exitAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startSendBird {
    if (self.channel != nil) {
        self.previousMessageQuery = [self.channel createPreviousMessageListQuery];
        [self.channel enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            [self loadMessages:LLONG_MAX initial:YES];
        }];
    }
}

- (void)loadMessages:(long long)ts initial:(BOOL)initial {
    if (self.isLoading) {
        return;
    }
    
    if (!self.hasPrev) {
        return;
    }
    
    self.isLoading = YES;
    
    __weak OpenChatViewController *weakSelf = self;
    [self.previousMessageQuery loadPreviousMessagesWithLimit:30 reverse:!initial completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
        OpenChatViewController *strongSelf = weakSelf;
        if (error != nil) {
            NSLog(@"Loading previous message error: %@", error);
            
            return;
        }
        
        if (messages != nil && [messages count] > 0) {
            int msgCount = 0;
            
            for (SBDBaseMessage *message in messages) {
                if ([message isKindOfClass:[SBDUserMessage class]]) {
                    NSLog(@"Message Type: MESG, Timestamp: %lld", message.createdAt);
                }
                else if ([message isKindOfClass:[SBDFileMessage class]]) {
                    NSLog(@"Message Type: FILE, Timestamp: %lld", message.createdAt);
                }
                else if ([message isKindOfClass:[SBDAdminMessage class]]) {
                    NSLog(@"Message Type: ADMM, Timestamp: %lld", message.createdAt);
                }
                
                if (message.createdAt < strongSelf.firstMessageTimestamp) {
                    strongSelf.firstMessageTimestamp = message.createdAt;
                }
                
                JSQSBMessage *jsqsbmsg = nil;
                
                if ([message isKindOfClass:[SBDUserMessage class]]) {
                    NSString *senderId = ((SBDUserMessage *)message).sender.userId;
                    NSString *senderImage = ((SBDUserMessage *)message).sender.profileUrl;
                    NSString *senderName = ((SBDUserMessage *)message).sender.nickname;
                    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:((SBDUserMessage *)message).createdAt / 1000];
                    NSString *messageText = ((SBDUserMessage *)message).message;
                    
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
                    
                    jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate text:messageText];
                    jsqsbmsg.message = message;
                    msgCount += 1;
                }
                else if ([message isKindOfClass:[SBDFileMessage class]]) {
                    NSString *senderId = ((SBDFileMessage *)message).sender.userId;
                    NSString *senderImage = ((SBDFileMessage *)message).sender.profileUrl;
                    NSString *senderName = ((SBDFileMessage *)message).sender.nickname;
                    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:((SBDFileMessage *)message).createdAt / 1000];
                    NSString *url = ((SBDFileMessage *)message).url;
                    NSString *type = ((SBDFileMessage *)message).type;
                    
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
                    
                    if ([type hasPrefix:@"image"]) {
                        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageURL:url];
                        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:photoItem];
                    }
                    else if ([type hasPrefix:@"video"]) {
                        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:url] isReadyToPlay:YES];
                        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:videoItem];
                    }
                    else {
                        JSQFileMediaItem *fileItem = [[JSQFileMediaItem alloc] initWithFileURL:[NSURL URLWithString:url]];
                        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:fileItem];
                    }
                    jsqsbmsg.message = message;
                    msgCount += 1;
                }
                else if ([message isKindOfClass:[SBDAdminMessage class]]) {
                    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:((SBDUserMessage *)message).createdAt / 1000];
                    NSString *messageText = ((SBDAdminMessage *)message).message;

                    jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:msgDate text:messageText];
                    jsqsbmsg.message = message;
                    msgCount += 1;
                }
                
                if (initial) {
                    [self.messages addObject:jsqsbmsg];
                }
                else {
                    [self.messages insertObject:jsqsbmsg atIndex:0];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                
                if (initial) {
                    [self scrollToBottomAnimated:NO];
                }
                else {
                    unsigned long totalMsgCount = [self.collectionView numberOfItemsInSection:0];
                    if (msgCount - 1 > 0 && totalMsgCount > 0) {
                        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(msgCount - 1) inSection:0]
                                                    atScrollPosition:UICollectionViewScrollPositionTop
                                                            animated:NO];
                    }
                }
            });
            
            self.isLoading = NO;
        }
        else {
            self.hasPrev = NO;
            self.isLoading = NO;
        }
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
    
    if ([message.senderId length] == 0) {
        return self.neutralBubbleImageData;
    }
    else {
        if ([message.senderId isEqualToString:self.senderId]) {
            return self.outgoingBubbleImageData;
        }
        
        return self.incomingBubbleImageData;
    }
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
            [cell setUnreadCount:0];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    [cell setUnreadCount:0];
    
    if (indexPath.row == 0) {
        [self loadMessages:self.firstMessageTimestamp initial:NO];
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if (action == @selector(customAction:)) {
//        return YES;
//    }
//    
//    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//{
//    if (action == @selector(customAction:)) {
//        [self customAction:sender];
//        return;
//    }
//    
//    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
//}
//
//- (void)customAction:(id)sender
//{
//    NSLog(@"Custom action received! Sender: %@", sender);
//    
//    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
//                                message:nil
//                               delegate:nil
//                      cancelButtonTitle:@"OK"
//                      otherButtonTitles:nil]
//     show];
//}



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
    NSLog(@"Tapped message bubble! %lu", indexPath.row);
    JSQSBMessage *jsqMessage = self.messages[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteMessageAction = nil;
    UIAlertAction *blockUserAction = nil;
    UIAlertAction *openFileAction = nil;
    
    if ([jsqMessage.message isKindOfClass:[SBDBaseMessage class]]) {
        __block SBDBaseMessage *baseMessage = (SBDBaseMessage *)jsqMessage.message;
        if ([baseMessage isKindOfClass:[SBDUserMessage class]]) {
            SBDUser *sender = ((SBDUserMessage *)baseMessage).sender;
            
            if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                deleteMessageAction = [UIAlertAction actionWithTitle:@"Delete the message" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    __block NSIndexPath *selectedMessageIndexPath = indexPath;
                    [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                        if (error != nil) {
                            
                        }
                        else {
                            [collectionView.dataSource collectionView:collectionView didDeleteMessageAtIndexPath:selectedMessageIndexPath];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [collectionView deleteItemsAtIndexPaths:@[selectedMessageIndexPath]];
                                [collectionView.collectionViewLayout invalidateLayout];
                            });
                        }
                    }];
                }];
            }
            else {
                blockUserAction = [UIAlertAction actionWithTitle:@"Block user" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [SBDMain blockUser:sender completionHandler:^(SBDUser * _Nullable blockedUser, SBDError * _Nullable error) {
                        if (error != nil) {
                            
                        }
                        else {
                            
                        }
                    }];
                }];
            }
        }
        else if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
            SBDFileMessage *fileMessage = (SBDFileMessage *)baseMessage;
            SBDUser *sender = ((SBDFileMessage *)baseMessage).sender;
            __block NSString *type = fileMessage.type;
            __block NSString *url = fileMessage.url;
            
            if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                deleteMessageAction = [UIAlertAction actionWithTitle:@"Delete the message" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    __block NSIndexPath *selectedMessageIndexPath = indexPath;
                    [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                        if (error != nil) {
                            
                        }
                        else {
                            [collectionView.dataSource collectionView:collectionView didDeleteMessageAtIndexPath:selectedMessageIndexPath];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [collectionView deleteItemsAtIndexPaths:@[selectedMessageIndexPath]];
                                [collectionView.collectionViewLayout invalidateLayout];
                            });
                        }
                    }];
                }];
            }
            else {
                blockUserAction = [UIAlertAction actionWithTitle:@"Block user" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [SBDMain blockUser:sender completionHandler:^(SBDUser * _Nullable blockedUser, SBDError * _Nullable error) {
                        if (error != nil) {
                            
                        }
                        else {
                            
                        }
                    }];
                }];
            }

            if ([type hasPrefix:@"video"]) {
                openFileAction = [UIAlertAction actionWithTitle:@"Play video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *videoUrl = [NSURL URLWithString:url];
                    AVPlayer *player = [[AVPlayer alloc] initWithURL:videoUrl];
                    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                    vc.player = player;
                    
                    [self presentViewController:vc animated:YES completion:^{
                        [player play];
                    }];
                }];
            }
            else if ([type hasPrefix:@"audio"]) {
                openFileAction = [UIAlertAction actionWithTitle:@"Play audio" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *audioUrl = [NSURL URLWithString:url];
                    AVPlayer *player = [[AVPlayer alloc] initWithURL:audioUrl];
                    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                    vc.player = player;
                    
                    [self presentViewController:vc animated:YES completion:^{
                        [player play];
                    }];
                }];
            }
            else if ([type hasPrefix:@"image"]) {
                openFileAction = [UIAlertAction actionWithTitle:@"Open image on Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *imageUrl = [NSURL URLWithString:url];
                    [[UIApplication sharedApplication] openURL:imageUrl];
                }];
            }
            else {
                // TODO: Download file.
            }
        }
        else if ([baseMessage isKindOfClass:[SBDAdminMessage class]]) {
            
        }
        
        [alert addAction:closeAction];
        if (blockUserAction != nil) {
            [alert addAction:blockUserAction];
        }
        if (openFileAction != nil) {
            [alert addAction:openFileAction];
        }
        if (deleteMessageAction != nil) {
            [alert addAction:deleteMessageAction];
        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }
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
        [self.channel sendUserMessage:text completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
            }
            else {
                if ([userMessage createdAt] > self.lastMessageTimestamp) {
                    self.lastMessageTimestamp = [userMessage createdAt];
                }
                
                if ([userMessage createdAt] < self.firstMessageTimestamp) {
                    self.firstMessageTimestamp = [userMessage createdAt];
                }
                
                JSQSBMessage *jsqsbmsg = nil;
                
                NSString *senderId = [[userMessage sender] userId];
                NSString *senderImage = [[userMessage sender] profileUrl];
                NSString *senderName = [[userMessage sender] nickname];
                NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[userMessage createdAt] / 1000];
                NSString *messageText = [userMessage message];
                
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
                if (senderName != nil) {
                    [self.users setObject:senderName forKey:senderId];
                }
                else {
                    [self.users setObject:@"UK" forKey:senderId];
                }
                
                jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate text:messageText];
                jsqsbmsg.message = userMessage;
                
                [self.messages addObject:jsqsbmsg];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionView reloadData];
                        [self scrollToBottomAnimated:NO];
                        
                        [[[self.inputToolbar contentView] textView] setText:@""];
                    });
                });
            }
        }];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    [self presentViewController:mediaUI animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __block UIImage *originalImage, *editedImage, *imageToUse;
    __block NSURL *imagePath;
    __block NSString *imageName;
    __block NSString *imageType;
    
    __weak OpenChatViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        OpenChatViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            editedImage = (UIImage *) [info objectForKey:
                                       UIImagePickerControllerEditedImage];
            originalImage = (UIImage *) [info objectForKey:
                                         UIImagePickerControllerOriginalImage];
            NSURL *refUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            imageName = [refUrl lastPathComponent];
            
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
            
            
            NSData *imageFileData = nil;
            NSString *extentionOfFile = [imageName substringFromIndex:[imageName rangeOfString:@"."].location + 1];
            
            if ([extentionOfFile caseInsensitiveCompare:@"png"]) {
                imageType = @"image/png";
                imageFileData = UIImagePNGRepresentation(newImage);
            }
            else {
                imageType = @"image/jpg";
                imageFileData = UIImageJPEGRepresentation(newImage, 1.0);
            }

            [strongSelf.channel sendFileMessageWithBinaryData:imageFileData filename:imageName type:imageType size:imageFileData.length data:@"" completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                if (error != nil) {
                    return;
                }
                
                if (fileMessage != nil) {
                    NSString *senderId = [[fileMessage sender] userId];
                    NSString *senderImage = [[fileMessage sender] profileUrl];
                    NSString *senderName = [[fileMessage sender] nickname];
                    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[fileMessage createdAt] / 1000];
                    NSString *url = [fileMessage url];
                    
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
                    JSQSBMessage *jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:photoItem];
                    
                    [strongSelf.messages addObject:jsqsbmsg];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.collectionView reloadData];
                            [strongSelf scrollToBottomAnimated:NO];
                        });
                    });
                }
            }];
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            imageName = [videoURL lastPathComponent];
            
            NSString *extentionOfFile = [imageName substringFromIndex:[imageName rangeOfString:@"."].location + 1];
            
            if ([extentionOfFile caseInsensitiveCompare:@"mov"]) {
                imageType = @"video/quicktime";
            }
            else if ([extentionOfFile caseInsensitiveCompare:@"mp4"]) {
                imageType = @"video/mp4";
            }
            else {
                imageType = @"video/mpeg";
            }
            
            [strongSelf.channel sendFileMessageWithBinaryData:videoFileData filename:imageName type:imageType size:videoFileData.length data:@"" completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                if (error != nil) {
                    return;
                }
                
                if (fileMessage != nil) {
                    NSString *senderId = [[fileMessage sender] userId];
                    NSString *senderImage = [[fileMessage sender] profileUrl];
                    NSString *senderName = [[fileMessage sender] nickname];
                    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[fileMessage createdAt] / 1000];
                    NSString *url = [fileMessage url];
                    
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
                    
                    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:url] isReadyToPlay:YES];
                    JSQSBMessage *jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate media:videoItem];
                    
                    [strongSelf.messages addObject:jsqsbmsg];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.collectionView reloadData];
                            [strongSelf scrollToBottomAnimated:NO];
                        });
                    });
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - SBDConnectionDelegate
- (void)didStartReconnection {
    NSLog(@"didStartReconnection in OpenChatViewController");
    self.lastMessageTimestamp = LLONG_MIN;
    self.firstMessageTimestamp = LLONG_MAX;
    
    [self.messages removeAllObjects];
    [self.collectionView reloadData];
}

- (void)didSucceedReconnection {
    NSLog(@"didSucceedReconnection delegate in OpenChatViewController");
    self.previousMessageQuery = [self.channel createPreviousMessageListQuery];
    [self loadMessages:LLONG_MAX initial:YES];
}

- (void)didFailReconnection {
    NSLog(@"didFailReconnection delegate in OpenChatViewController");
}

#pragma mark - SBDBaseChannelDelegate
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    NSLog(@"channel:didReceiveMessage: delegate in OpenChatViewController");
    
    JSQSBMessage *jsqsbmsg = nil;
    
    if (![sender.channelUrl isEqualToString:self.channel.channelUrl]) {
        return;
    }
    
    if ([message isKindOfClass:[SBDUserMessage class]]) {
        NSString *senderId = [[((SBDUserMessage *)message) sender] userId];
        NSString *senderImage = [[((SBDUserMessage *)message) sender] profileUrl];
        NSString *senderName = [[((SBDUserMessage *)message) sender] nickname];
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[message createdAt] / 1000];
        NSString *messageText = [((SBDUserMessage *)message) message];
        
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
        
        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:msgDate text:messageText];
        jsqsbmsg.message = message;
    }
    else if ([message isKindOfClass:[SBDFileMessage class]]) {
        NSString *senderId = [[((SBDFileMessage *)message) sender] userId];
        NSString *senderImage = [[((SBDFileMessage *)message) sender] profileUrl];
        NSString *senderName = [[((SBDFileMessage *)message) sender] nickname];
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[message createdAt] / 1000];
        NSString *url = [((SBDFileMessage *)message) url];
        
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
    }
    else if ([message isKindOfClass:[SBDAdminMessage class]]) {
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:[message createdAt] / 1000];
        NSString *messageText = [((SBDUserMessage *)message) message];
        
        jsqsbmsg = [[JSQSBMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:msgDate text:messageText];
        jsqsbmsg.message = message;
    }
    
    if ([message createdAt] > self.lastMessageTimestamp) {
        self.lastMessageTimestamp = [message createdAt];
    }
    
    if ([message createdAt] < self.firstMessageTimestamp) {
        self.firstMessageTimestamp = [message createdAt];
    }
    
    if (jsqsbmsg != nil) {
        [self.messages addObject:jsqsbmsg];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:NO];
        });
    });
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    NSLog(@"didReceiveChannelEvent:channelEvent: delegate in OpenChatViewController");
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    NSLog(@"channelDidUpdateTypingStatus: delegate in OpenChatViewController");
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidJoin: delegate in OpenChatViewController");
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidLeave: delegate in OpenChatViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidEnter: delegate in OpenChatViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidExit:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userDidExit: delegate in OpenChatViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasMuted:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userWasMuted: delegate in OpenChatViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnmuted:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userWasUnmuted: delegate in OpenChatViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasBanned:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userWasBanned: delegate in OpenChatViewController");
}

- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnbanned:(SBDUser * _Nonnull)user {
    NSLog(@"channel:userWasUnbanned: delegate in OpenChatViewController");
}

- (void)channelWasFrozen:(SBDOpenChannel * _Nonnull)sender {
    NSLog(@"channelWasFrozen: delegate in OpenChatViewController");
}

- (void)channelWasUnfrozen:(SBDOpenChannel * _Nonnull)sender {
    NSLog(@"channelWasUnfrozen: delegate in OpenChatViewController");
}

- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender {
    NSLog(@"channelWasChanged: delegate in OpenChatViewController");
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    NSLog(@"channelWasDeleted:channelType: delegate in OpenChatViewController");
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    NSLog(@"channel:messageWasDeleted: delegate in OpenChatViewController");
    
    for (JSQSBMessage *msg in self.messages) {
        if (msg.message.messageId == messageId) {
            NSUInteger row = [self.messages indexOfObject:msg];
            NSIndexPath *deletedMessageIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
            
            [self.collectionView.dataSource collectionView:self.collectionView didDeleteMessageAtIndexPath:deletedMessageIndexPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView deleteItemsAtIndexPaths:@[deletedMessageIndexPath]];
                [self.collectionView.collectionViewLayout invalidateLayout];
            });
            
            break;
        }
    }
}

@end
