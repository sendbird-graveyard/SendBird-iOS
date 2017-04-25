//
//  OpenChannelChattingViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>

#import "OpenChannelChattingViewController.h"
#import "ParticipantListViewController.h"
#import "BlockedUserListViewController.h"
#import "NSBundle+SendBird.h"
#import "GroupChannelChattingViewController.h"
#import "Utils.h"

@interface OpenChannelChattingViewController ()

@property (weak, nonatomic) IBOutlet ChattingView *chattingView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) SBDPreviousMessageListQuery *messageQuery;
@property (strong, nonatomic) NSString *delegateIdentifier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (atomic) BOOL hasNext;
@property (atomic) BOOL refreshInViewDidAppear;

@property (atomic) BOOL isLoading;
@property (atomic) BOOL keyboardShown;

@end

@implementation OpenChannelChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, self.view.frame.size.width - 100)];
    titleView.attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:@"%@(%ld)", self.channel.name, (long)self.channel.participantCount] subTitle:nil];
    titleView.numberOfLines = 2;
    titleView.textAlignment = NSTextAlignmentCenter;
    
    UITapGestureRecognizer *titleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickReconnect)];
    titleView.userInteractionEnabled = YES;
    [titleView addGestureRecognizer:titleTapRecognizer];
    
    self.navItem.titleView = titleView;

    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;
    
    UIBarButtonItem *leftCloseItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    UIBarButtonItem *rightOpenMoreMenuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_more"] style:UIBarButtonItemStyleDone target:self action:@selector(openMoreMenu)];
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftCloseItem];
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, rightOpenMoreMenuItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    self.delegateIdentifier = self.description;
    [SBDMain addChannelDelegate:self identifier:self.delegateIdentifier];
    [SBDMain addConnectionDelegate:self identifier:self.delegateIdentifier];
    
    self.hasNext = YES;
    self.refreshInViewDidAppear = YES;
    self.isLoading = NO;
    
    [self.chattingView.fileAttachButton addTarget:self action:@selector(sendFileMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.chattingView.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.refreshInViewDidAppear) {
        [self.chattingView initChattingView];
        self.chattingView.delegate = self;
        
        [self loadPreviousMessage:YES];
    }
    
    self.refreshInViewDidAppear = YES;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    self.keyboardShown = YES;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = keyboardFrameBeginRect.size.height;
        [self.view layoutIfNeeded];
        self.chattingView.stopMeasuringVelocity = YES;
        [self.chattingView scrollToBottomWithForce:NO];
    });
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.keyboardShown = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = 0;
        [self.view layoutIfNeeded];
        [self.chattingView scrollToBottomWithForce:NO];
    });
}

- (void)close {
    [self.channel exitChannelWithCompletionHandler:^(SBDError * _Nullable error) {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }];
}

- (void)openMoreMenu {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *seeParticipantListAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"SeeParticipantListButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ParticipantListViewController *plvc = [[ParticipantListViewController alloc] init];
            [plvc setChannel:self.channel];
            self.refreshInViewDidAppear = NO;
            [self presentViewController:plvc animated:NO completion:nil];
        });
    }];
    UIAlertAction *seeBlockedUserListAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"SeeBlockedUserListButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BlockedUserListViewController *plvc = [[BlockedUserListViewController alloc] init];
            [plvc setChannel:self.channel];
            self.refreshInViewDidAppear = NO;
            [self presentViewController:plvc animated:NO completion:nil];
        });
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:seeParticipantListAction];
    [vc addAction:seeBlockedUserListAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadPreviousMessage:(BOOL)initial {
    if (initial) {
        [self.chattingView.resendableFileData removeAllObjects];
        [self.chattingView.resendableMessages removeAllObjects];
        [self.chattingView.preSendFileData removeAllObjects];
        [self.chattingView.preSendMessages removeAllObjects];
        
        self.chattingView.chattingTableView.hidden = YES;
        self.messageQuery = [self.channel createPreviousMessageListQuery];
        self.hasNext = YES;
        [self.chattingView.messages removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView.chattingTableView reloadData];
        });
    }
    
    if (self.hasNext == NO) {
        self.chattingView.chattingTableView.hidden = NO;
        return;
    }
    
    if (self.isLoading) {
        self.chattingView.chattingTableView.hidden = NO;
        return;
    }
    
    self.isLoading = YES;
    
    [self.messageQuery loadPreviousMessagesWithLimit:30 reverse:!initial completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            self.chattingView.chattingTableView.hidden = NO;
            self.isLoading = NO;
            
            return;
        }
        
        if (messages.count == 0) {
            self.hasNext = NO;
        }
        
        if (initial) {
            for (SBDBaseMessage *message in messages) {
                [self.chattingView.messages addObject:message];
            }
        }
        else {
            for (SBDBaseMessage *message in messages) {
                [self.chattingView.messages insertObject:message atIndex:0];
            }
        }

        if (initial) {
            self.chattingView.initialLoading = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chattingView.chattingTableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView scrollToBottomWithForce:YES];
                    self.chattingView.chattingTableView.hidden = NO;
                });
            });
            
            self.chattingView.initialLoading = NO;
            self.isLoading = NO;
        }
        else {
            if (messages.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView.chattingTableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chattingView scrollToPosition:messages.count - 1];
                        self.chattingView.chattingTableView.hidden = NO;
                    });
                });
            }
            self.isLoading = NO;
        }
    }];
}

- (void)sendMessage {
    if (self.chattingView.messageTextView.text.length > 0) {
        NSString *message = [self.chattingView.messageTextView.text copy];
        self.chattingView.messageTextView.text = @"";
        SBDUserMessage *preSendMessage = [self.channel sendUserMessage:message data:@"test_data" customType:@"test_custom_type" targetLanguages:@[@"ar", @"de", @"fr", @"nl", @"ja", @"ko", @"pt", @"es", @"zh-CHS"] completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                SBDUserMessage *preSendMessage = (SBDUserMessage *)self.chattingView.preSendMessages[userMessage.requestId];
                [self.chattingView.preSendMessages removeObjectForKey:userMessage.requestId];
                
                if (error != nil) {
                    self.chattingView.resendableMessages[userMessage.requestId] = userMessage;
                    [self.chattingView.chattingTableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chattingView scrollToBottomWithForce:YES];
                    });
                    
                    return;
                }
                
                if (preSendMessage != nil) {
                    [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:preSendMessage] withObject:userMessage];
                }
                
                [self.chattingView.chattingTableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView scrollToBottomWithForce:YES];
                });
            });
        }];
        self.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.chattingView.messages addObject:preSendMessage];
        [self.chattingView.chattingTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView scrollToBottomWithForce:YES];
        });
    }
}

- (void)sendFileMessage {
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    self.refreshInViewDidAppear = NO;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (void)clickReconnect {
    if ([SBDMain getConnectState] != SBDWebSocketOpen && [SBDMain getConnectState] != SBDWebSocketConnecting) {
        [SBDMain reconnect];
    }
}

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection {
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:@"%@(%ld)", self.channel.name, (long)self.channel.participantCount] subTitle:[NSBundle sbLocalizedStringForKey:@"ReconnectingSubTitle"]];
    }
}

- (void)didSucceedReconnection {
    [self loadPreviousMessage:YES];
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:@"%@(%ld)", self.channel.name, (long)self.channel.participantCount] subTitle:[NSBundle sbLocalizedStringForKey:@"ReconnectedSubTitle"]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
            ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:@"%@(%ld)", self.channel.name, (long)self.channel.participantCount] subTitle:nil];
        }
    });
}

- (void)didFailReconnection {
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:@"%@(%ld)", self.channel.name, (long)self.channel.participantCount] subTitle:[NSBundle sbLocalizedStringForKey:@"ReconnectionFailedSubTitle"]];
    }
}


#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (sender == self.channel) {
        [self.chattingView.messages addObject:message];
        [self.chattingView.chattingTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView scrollToBottomWithForce:NO];
        });
    }
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    
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
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navItem.title = [NSString stringWithFormat:@"%@(%ld)", self.channel.name, (long)self.channel.participantCount];
        });
    }
}

- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ChannelDeletedTitle"] message:[NSBundle sbLocalizedStringForKey:@"ChannelDeletedMessage"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self close];
    }];
    [vc addAction:closeAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId {
    if (sender == self.channel) {
        for (SBDBaseMessage *message in self.chattingView.messages) {
            if (message.messageId == messageId) {
                [self.chattingView.messages removeObject:message];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView.chattingTableView reloadData];
                });
                break;
            }
        }
    }
}

#pragma mark - ChattingViewDelegate
- (void)loadMoreMessage:(UIView *)view {
    [self loadPreviousMessage:NO];
}

- (void)startTyping:(UIView *)view {
    
}

- (void)endTyping:(UIView *)view {
    
}

- (void)hideKeyboardWhenFastScrolling:(UIView *)view {
    if (self.keyboardShown == NO) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = 0;
        [self.view layoutIfNeeded];
        [self.chattingView scrollToBottomWithForce:NO];
    });
    [self.view endEditing:YES];
}

#pragma mark - MessageDelegate
- (void)clickProfileImage:(UITableViewCell *)viewCell user:(SBDUser *)user {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *startDistinctGroupChannel = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"OpenDistinctGroupChannel"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SBDGroupChannel createChannelWithUsers:@[user] isDistinct:YES completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
                vc.channel = channel;
                [self presentViewController:vc animated:NO completion:nil];
            });
        }];
    }];
    UIAlertAction *startNonDistinctGroupChannel = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"OpenNonDistinctGroupChannel"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SBDGroupChannel createChannelWithUsers:@[user] isDistinct:NO completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
                vc.channel = channel;
                [self presentViewController:vc animated:NO completion:nil];
            });
        }];
    }];
    UIAlertAction *blockUserAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"BlockUserButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SBDMain blockUser:user completionHandler:^(SBDUser * _Nullable blockedUser, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"UserBlockedTitle"] message:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"UserBlockedMessage"], user.nickname] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
            });
        }];
        
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:startDistinctGroupChannel];
    [vc addAction:startNonDistinctGroupChannel];
    [vc addAction:blockUserAction];
    [vc addAction:closeAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)clickMessage:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteMessageAction = nil;
    UIAlertAction *openFileAction = nil;
    NSMutableArray<UIAlertAction *> *openURLsAction = [[NSMutableArray alloc] init];
    
    if ([message isKindOfClass:[SBDBaseMessage class]]) {
        __block SBDBaseMessage *baseMessage = (SBDBaseMessage *)message;
        if ([baseMessage isKindOfClass:[SBDUserMessage class]]) {
            SBDUser *sender = ((SBDUserMessage *)baseMessage).sender;
            if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                deleteMessageAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"DeleteMessageButton"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                        if (error != nil) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:closeAction];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:alert animated:YES completion:nil];
                            });
                        }
                    }];
                }];
            }
            
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            if (error == nil) {
                NSArray *matches = [detector matchesInString:((SBDUserMessage *)message).message options:0 range:NSMakeRange(0, ((SBDUserMessage *)message).message.length)];
                for (NSTextCheckingResult *match in matches) {
                    __block NSURL *url = [match URL];
                    UIAlertAction *openURLAction = [UIAlertAction actionWithTitle:[url relativeString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        self.refreshInViewDidAppear = NO;
                        [[UIApplication sharedApplication] openURL:url];
                    }];
                    [openURLsAction addObject:openURLAction];
                }
            }
        }
        else if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
            SBDFileMessage *fileMessage = (SBDFileMessage *)baseMessage;
            SBDUser *sender = ((SBDFileMessage *)baseMessage).sender;
            __block NSString *type = fileMessage.type;
            __block NSString *url = fileMessage.url;
            
            if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                deleteMessageAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"DeleteMessageButton"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self.channel deleteMessage:baseMessage completionHandler:^(SBDError * _Nullable error) {
                        if (error != nil) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:closeAction];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:alert animated:YES completion:nil];
                            });
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.chattingView.chattingTableView reloadData];
                            });
                        }
                    }];
                }];
            }
            
            if ([type hasPrefix:@"video"]) {
                openFileAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"PlayVideoButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *videoUrl = [NSURL URLWithString:url];
                    AVPlayer *player = [[AVPlayer alloc] initWithURL:videoUrl];
                    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                    vc.player = player;
                    self.refreshInViewDidAppear = NO;
                    [self presentViewController:vc animated:YES completion:^{
                        [player play];
                    }];
                }];
            }
            else if ([type hasPrefix:@"audio"]) {
                openFileAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"PlayAudioButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *audioUrl = [NSURL URLWithString:url];
                    AVPlayer *player = [[AVPlayer alloc] initWithURL:audioUrl];
                    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                    vc.player = player;
                    self.refreshInViewDidAppear = NO;
                    [self presentViewController:vc animated:YES completion:^{
                        [player play];
                    }];
                }];
            }
            else if ([type hasPrefix:@"image"]) {
                openFileAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"OpenImageButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *imageUrl = [NSURL URLWithString:url];
                    self.refreshInViewDidAppear = NO;
                    [[UIApplication sharedApplication] openURL:imageUrl];
                }];
            }
            else {
                // TODO: Download file.
            }
        }
        else if ([baseMessage isKindOfClass:[SBDAdminMessage class]]) {
            return;
        }
        
        [alert addAction:closeAction];
        if (openFileAction != nil) {
            [alert addAction:openFileAction];
        }
        
        if (openURLsAction.count > 0) {
            for (UIAlertAction *action in openURLsAction) {
                [alert addAction:action];
            }
        }
        
        if (deleteMessageAction != nil) {
            [alert addAction:deleteMessageAction];
        }
        
        if (openFileAction != nil || openURLsAction.count > 0 || deleteMessageAction != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.refreshInViewDidAppear = NO;
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }
}

- (void)clickResend:(UIView *)view message:(SBDBaseMessage *)message {
    if ([message isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *resendableUserMessage = (SBDUserMessage *)message;
        NSArray<NSString *> *targetLanguages = nil;
        if (resendableUserMessage.translations != nil) {
            targetLanguages = [resendableUserMessage.translations allKeys];
        }
        SBDUserMessage *preSendMessage = [self.channel sendUserMessage:resendableUserMessage.message data:resendableUserMessage.data customType:resendableUserMessage.customType targetLanguages:targetLanguages completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                SBDUserMessage *preSendMessage = (SBDUserMessage *)self.chattingView.preSendMessages[userMessage.requestId];
                [self.chattingView.preSendMessages removeObjectForKey:userMessage.requestId];
                
                if (error != nil) {
                    self.chattingView.resendableMessages[userMessage.requestId] = userMessage;
                    [self.chattingView.chattingTableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chattingView scrollToBottomWithForce:YES];
                    });
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                if (preSendMessage != nil) {
                    [self.chattingView.messages removeObject:preSendMessage];
                    [self.chattingView.messages addObject:userMessage];
                }
                
                [self.chattingView.chattingTableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView scrollToBottomWithForce:YES];
                });
            });
        }];
        [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:resendableUserMessage] withObject:preSendMessage];
        self.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
        [self.chattingView.chattingTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView scrollToBottomWithForce:YES];
        });
    }
    else if ([message isKindOfClass:[SBDFileMessage class]]) {
        __block SBDFileMessage *resendableFileMessage = (SBDFileMessage *)message;
        
        NSMutableArray<SBDThumbnailSize *> *thumbnailsSizes = [[NSMutableArray alloc] init];
        for (SBDThumbnail *thumbnail in resendableFileMessage.thumbnails) {
            [thumbnailsSizes addObject:[SBDThumbnailSize makeWithMaxCGSize:thumbnail.maxSize]];
        }
        SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:(NSData *)self.chattingView.preSendFileData[resendableFileMessage.requestId][@"data"] filename:resendableFileMessage.name type:resendableFileMessage.type size:resendableFileMessage.size thumbnailSizes:thumbnailsSizes data:resendableFileMessage.data customType:resendableFileMessage.customType progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                SBDFileMessage *preSendMessage = (SBDFileMessage *)self.chattingView.preSendMessages[fileMessage.requestId];
                [self.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
                
                if (error != nil) {
                    self.chattingView.resendableMessages[fileMessage.requestId] = fileMessage;
                    self.chattingView.resendableFileData[fileMessage.requestId] = self.chattingView.resendableFileData[resendableFileMessage.requestId];
                    [self.chattingView.resendableFileData removeObjectForKey:resendableFileMessage.requestId];
                    [self.chattingView.chattingTableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chattingView scrollToBottomWithForce:YES];
                    });
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                if (preSendMessage != nil) {
                    [self.chattingView.messages removeObject:preSendMessage];
                    [self.chattingView.messages addObject:fileMessage];
                }
                
                [self.chattingView.chattingTableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView scrollToBottomWithForce:YES];
                });
            });
        }];
        [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:resendableFileMessage] withObject:preSendMessage];
        self.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
        self.chattingView.preSendFileData[preSendMessage.requestId] = self.chattingView.resendableFileData[resendableFileMessage.requestId];
        [self.chattingView.preSendFileData removeObjectForKey:resendableFileMessage.requestId];
        [self.chattingView.chattingTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView scrollToBottomWithForce:YES];
        });
    }
}

- (void)clickDelete:(UIView *)view message:(SBDBaseMessage *)message {
    [self.chattingView.messages removeObject:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chattingView.chattingTableView reloadData];
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak OpenChannelChattingViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        OpenChannelChattingViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            NSURL *imagePath;
            NSString *imageName;
            NSURL *refUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            
            imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            imageName = [refUrl lastPathComponent];
            
            NSString *ext = [imageName pathExtension];
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
            NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
            
            PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[imagePath] options:nil] lastObject];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = NO;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSNumber * isError = [info objectForKey:PHImageErrorKey];
                NSNumber * isCloud = [info objectForKey:PHImageResultIsInCloudKey];
                if ([isError boolValue] || [isCloud boolValue] || ! imageData) {
                    // fail
                } else {
                    // success, data is in imageData
                    /***********************************/
                    /* Thumbnail is a premium feature. */
                    /***********************************/
                    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
                    
                    SBDFileMessage *preSendMessage = [strongSelf.channel sendFileMessageWithBinaryData:imageData filename:[imageName lowercaseString] type:mimeType size:imageData.length thumbnailSizes:@[thumbnailSize] data:@"" customType:@"" progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                            SBDFileMessage *preSendMessage = (SBDFileMessage *)strongSelf.chattingView.preSendMessages[fileMessage.requestId];
                            [strongSelf.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
                            
                            if (error != nil) {
                                strongSelf.chattingView.resendableMessages[fileMessage.requestId] = preSendMessage;
                                strongSelf.chattingView.resendableFileData[preSendMessage.requestId] = @{
                                                                                                         @"data": imageData,
                                                                                                         @"type": mimeType
                                                                                                         };
                                [strongSelf.chattingView.chattingTableView reloadData];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.chattingView scrollToBottomWithForce:YES];
                                });
                                
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                                [alert addAction:closeAction];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [strongSelf presentViewController:alert animated:YES completion:nil];
                                });
                                
                                return;
                            }
                            
                            if (fileMessage != nil) {
                                [strongSelf.chattingView.resendableMessages removeObjectForKey:fileMessage.requestId];
                                [strongSelf.chattingView.resendableFileData removeObjectForKey:fileMessage.requestId];
                                [strongSelf.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:preSendMessage] withObject:fileMessage];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [strongSelf.chattingView.chattingTableView reloadData];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [strongSelf.chattingView scrollToBottomWithForce:YES];
                                    });
                                });
                            }
                        });
                    }];
                    
                    strongSelf.chattingView.preSendFileData[preSendMessage.requestId] = @{
                                                                                          @"data": imageData,
                                                                                          @"type": mimeType
                                                                                          };
                    strongSelf.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
                    [strongSelf.chattingView.messages addObject:preSendMessage];
                    [strongSelf.chattingView.chattingTableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.chattingView scrollToBottomWithForce:YES];
                    });
                }
            }];
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            NSString *videoName = [videoURL lastPathComponent];
            
            NSString *ext = [videoName pathExtension];
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
            NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
            
            SBDFileMessage *preSendMessage = [strongSelf.channel sendFileMessageWithBinaryData:videoFileData filename:videoName type:mimeType size:videoFileData.length thumbnailSizes:nil data:@"" customType:@"" progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    SBDFileMessage *preSendMessage = (SBDFileMessage *)strongSelf.chattingView.preSendMessages[fileMessage.requestId];
                    [strongSelf.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
                    
                    if (error != nil) {
                        strongSelf.chattingView.resendableMessages[fileMessage.requestId] = preSendMessage;
                        strongSelf.chattingView.resendableFileData[preSendMessage.requestId] = @{
                                                                                                 @"data": videoFileData,
                                                                                                 @"type": mimeType
                                                                                                 };
                        [strongSelf.chattingView.chattingTableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chattingView scrollToBottomWithForce:YES];
                        });
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:closeAction];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf presentViewController:alert animated:YES completion:nil];
                        });
                        
                        return;
                    }
                    
                    if (fileMessage != nil) {
                        [strongSelf.chattingView.resendableMessages removeObjectForKey:fileMessage.requestId];
                        [strongSelf.chattingView.resendableFileData removeObjectForKey:fileMessage.requestId];
                        [strongSelf.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:preSendMessage] withObject:fileMessage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.chattingView.chattingTableView reloadData];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf.chattingView scrollToBottomWithForce:YES];
                            });
                        });
                    }
                });
            }];
            
            strongSelf.chattingView.preSendFileData[preSendMessage.requestId] = @{
                                                                                  @"data": videoFileData,
                                                                                  @"type": mimeType
                                                                                  };
            strongSelf.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
            [strongSelf.chattingView.messages addObject:preSendMessage];
            [strongSelf.chattingView.chattingTableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.chattingView scrollToBottomWithForce:YES];
            });
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
