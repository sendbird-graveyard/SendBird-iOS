//
//  GroupChannelChattingViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/27/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "GroupChannelChattingViewController.h"
#import "MemberListViewController.h"
#import "BlockedUserListViewController.h"
#import "NSBundle+SendBird.h"

@interface GroupChannelChattingViewController ()

@property (weak, nonatomic) IBOutlet ChattingView *chattingView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) SBDPreviousMessageListQuery *messageQuery;
@property (strong, nonatomic) NSString *delegateIdentifier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (atomic) BOOL hasNext;
@property (atomic) BOOL refreshInViewDidAppear;

@property (atomic) BOOL isLoading;

@end

@implementation GroupChannelChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount];
    
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
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = keyboardFrameBeginRect.size.height;
        [self.view layoutIfNeeded];
        self.chattingView.stopMeasuringVelocity = YES;
        [self.chattingView scrollToBottom];
    });
}

- (void)keyboardDidHide:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomMargin.constant = 0;
        [self.view layoutIfNeeded];
        [self.chattingView scrollToBottom];
    });
}

- (void)close {
    [SBDMain removeChannelDelegateForIdentifier:self.delegateIdentifier];
    [SBDMain removeConnectionDelegateForIdentifier:self.delegateIdentifier];
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)openMoreMenu {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *seeMemberListAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"SeeMemberListButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MemberListViewController *mlvc = [[MemberListViewController alloc] init];
            [mlvc setChannel:self.channel];
            self.refreshInViewDidAppear = NO;
            [self presentViewController:mlvc animated:NO completion:nil];
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
    [vc addAction:seeMemberListAction];
    [vc addAction:seeBlockedUserListAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadPreviousMessage:(BOOL)initial {
    if (initial) {
        self.messageQuery = [self.channel createPreviousMessageListQuery];
        self.hasNext = YES;
        [self.chattingView.messages removeAllObjects];
        [self.chattingView.chattingTableView reloadData];
    }
    
    if (self.hasNext == NO) {
        return;
    }

    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.messageQuery loadPreviousMessagesWithLimit:40 reverse:!initial completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            
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
            
            [self.channel markAsRead];
        }
        else {
            for (SBDBaseMessage *message in messages) {
                [self.chattingView.messages insertObject:message atIndex:0];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (initial) {
                self.chattingView.chattingTableView.hidden = YES;
                self.chattingView.initialLoading = YES;
                [self.chattingView.chattingTableView reloadData];
                [self.chattingView scrollToBottom];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(250 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    self.chattingView.chattingTableView.hidden = NO;
                    self.chattingView.initialLoading = NO;
                    self.isLoading = NO;
                });
            }
            else {
                [self.chattingView.chattingTableView reloadData];
                if (messages.count > 0) {
                    [self.chattingView scrollToPosition:messages.count - 1];
                }
                self.isLoading = NO;
            }
        });
    }];
}

- (void)sendMessage {
    if (self.chattingView.messageTextView.text.length > 0) {
        [self.channel endTyping];
        NSString *message = [self.chattingView.messageTextView.text copy];
        self.chattingView.messageTextView.text = @"";
        [self.channel sendUserMessage:message completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            if (error != nil) {
                self.chattingView.resendableMessages[userMessage.requestId] = userMessage;
            }
            
            [self.chattingView.messages addObject:userMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chattingView.chattingTableView reloadData];
                [self.chattingView scrollToBottom];
            });
        }];
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

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection {
    
}

- (void)didSucceedReconnection {
    [self loadPreviousMessage:YES];
}

- (void)didFailReconnection {
    
}

#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (sender == self.channel) {
        [self.channel markAsRead];
        
        [self.chattingView.messages addObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView.chattingTableView reloadData];
            [self.chattingView scrollToBottom];
        });
    }
}

- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender {
    if (sender == self.channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView.chattingTableView reloadData];
        });
    }
}

- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    if (sender.getTypingMembers.count == 0) {
        [self.chattingView endTypingIndicator];
    }
    else {
        if (sender.getTypingMembers.count == 1) {
            [self.chattingView startTypingIndicator:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"TypingMessageSingular"], sender.getTypingMembers[0].nickname]];
        }
        else {
            [self.chattingView startTypingIndicator:[NSBundle sbLocalizedStringForKey:@"TypingMessagePlural"]];
        }
    }
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
            self.navItem.title = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount];
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
    [self.channel startTyping];
}

- (void)endTyping:(UIView *)view {
    [self.channel endTyping];
}

- (void)hideKeyboardWhenFastScrolling:(UIView *)view {
    [self.view endEditing:YES];
}

#pragma mark - MessageDelegate
- (void)clickProfileImage:(UITableViewCell *)viewCell user:(SBDUser *)user {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *seeBlockUserAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"BlockUserButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    [vc addAction:seeBlockUserAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __block UIImage *originalImage, *editedImage, *imageToUse;
    __block NSURL *imagePath;
    __block NSString *imageName;
    __block NSString *imageType;
    
    __weak GroupChannelChattingViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        GroupChannelChattingViewController *strongSelf = weakSelf;
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
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                if (fileMessage != nil) {
                    [strongSelf.chattingView.messages addObject:fileMessage];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.chattingView.chattingTableView reloadData];
                            [strongSelf.chattingView scrollToBottom];
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
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                    
                    return;
                }
                
                if (fileMessage != nil) {
                    [strongSelf.chattingView.messages addObject:fileMessage];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.chattingView.chattingTableView reloadData];
                            [strongSelf.chattingView scrollToBottom];
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

@end
