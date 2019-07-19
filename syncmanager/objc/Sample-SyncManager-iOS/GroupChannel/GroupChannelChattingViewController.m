//
//  GroupChannelChattingViewController.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/27/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <HTMLKit/HTMLKit.h>

#import "AppDelegate.h"
#import "GroupChannelChattingViewController.h"
#import "MemberListViewController.h"
#import "Utils+View.h"
#import "ChatImage.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "CreateGroupChannelUserListViewController.h"
#import "ConnectionManager.h"
#import "Application.h"
#import <SendBirdSyncManager/SendBirdSyncManager.h>

@interface GroupChannelChattingViewController () <SBDChannelDelegate, SBSMMessageCollectionDelegate>

@property (weak, nonatomic) IBOutlet ChattingView *chattingView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) NSString *delegateIdentifier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet UIView *imageViewerLoadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageViewerLoadingIndicator;
@property (weak, nonatomic) IBOutlet UINavigationItem *imageViewerLoadingViewNavItem;

@property (atomic) BOOL refreshInViewDidAppear;

@property (atomic, getter=isLoading) BOOL loading;
@property (atomic) BOOL keyboardShown;

@property (strong, nonatomic) NYTPhotosViewController *photosViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeight;

/**
 *  new properties with message manager
 */
@property (strong, nonatomic, nullable) SBSMMessageCollection *messageCollection;
@property (strong, atomic, nonnull) SBSMOperationQueue *collectionQueue;

@end

@implementation GroupChannelChattingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        _delegateIdentifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureView];

    self.collectionQueue = [SBSMOperationQueue queue];
    
    [SBDMain addChannelDelegate:self identifier:self.delegateIdentifier];
    
    self.messageCollection.delegate = self;
    [self fetchPreviousMessages];
}

- (void)configureView {
    // Do any additional setup after loading the view from its nib.
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 64)];
    NSString *title = [NSString stringWithFormat:@"Group Channel (%ld)", self.channel.memberCount];
    titleView.attributedText = [Utils generateNavigationTitle:title subTitle:nil];
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
    
    UIBarButtonItem *negativeLeftSpacerForImageViewerLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacerForImageViewerLoading.width = -2;
    
    UIBarButtonItem *leftCloseItemForImageViewerLoading = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(hideImageViewerLoading)];
    
    self.imageViewerLoadingViewNavItem.leftBarButtonItems = @[negativeLeftSpacerForImageViewerLoading, leftCloseItemForImageViewerLoading];
    
    self.chattingView.delegate = self;
    [self.chattingView configureChattingViewWithChannel:self.channel];
    [self.chattingView.fileAttachButton addTarget:self action:@selector(selectFileAttachment) forControlEvents:UIControlEventTouchUpInside];
    [self.chattingView.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    if (self.messageCollection != nil) {
        self.messageCollection.delegate = nil;
    }
    
    if (self.chattingView != nil) {
        self.chattingView.delegate = nil;
    }
    
    [SBDMain removeChannelDelegateForIdentifier:self.delegateIdentifier];
    [self.messageCollection remove];
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
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)openMoreMenu {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *seeMemberListAction = [UIAlertAction actionWithTitle:@"Members" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MemberListViewController *mlvc = [[MemberListViewController alloc] init];
            [mlvc setChannel:self.channel];
            [self presentViewController:mlvc animated:NO completion:nil];
        });
    }];

    UIAlertAction *inviteUserListAction = [UIAlertAction actionWithTitle:@"Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CreateGroupChannelUserListViewController *vc = [[CreateGroupChannelUserListViewController alloc] init];
            vc.userSelectionMode = 1;
            vc.groupChannel = self.channel;
            [self presentViewController:vc animated:NO completion:nil];
        });
    }];
    
    UIAlertAction *resetManager = [UIAlertAction actionWithTitle:@"Reset Message List" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.messageCollection resetViewpointTimestamp:LONG_LONG_MAX];
    }];
    [vc addAction:resetManager];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:seeMemberListAction];
    [vc addAction:inviteUserListAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)sendUrlPreview:(NSURL * _Nonnull)url message:(NSString * _Nonnull)message tempModel:(OutgoingGeneralUrlPreviewTempModel * _Nonnull)aTempModel {
    NSURL *preViewUrl = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            [self sendMessageWithReplacement:aTempModel];
            [session invalidateAndCancel];
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *contentType = (NSString *)httpResponse.allHeaderFields[@"Content-Type"];
        if ([contentType containsString:@"text/html"]) {
            NSString *htmlBody = [NSString stringWithUTF8String:[data bytes]];

            HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlBody];
            HTMLDocument *document = [parser parseDocument];
            HTMLElement *head = document.head;
            
            NSString *title = nil;
            NSString *desc = nil;
            
            NSString *ogUrl = nil;
            NSString *ogSiteName = nil;
            NSString *ogTitle = nil;
            NSString *ogDesc = nil;
            NSString *ogImage = nil;
            
            NSString *twtUrl = nil;
            NSString *twtSiteName = nil;
            NSString *twtTitle = nil;
            NSString *twtDesc = nil;
            NSString *twtImage = nil;
            
            NSString *finalUrl = nil;
            NSString *finalTitle = nil;
            NSString *finalSiteName = nil;
            NSString *finalDesc = nil;
            NSString *finalImage = nil;
            
            for (id node in head.childNodes) {
                if ([node isKindOfClass:[HTMLElement class]]) {
                    HTMLElement *element = (HTMLElement *)node;
                    if ([element.tagName isEqualToString:@"meta"]) {
                        if (element.attributes[@"property"] != nil && ![element.attributes[@"property"] isKindOfClass:[NSNull class]]) {
                            if (ogUrl == nil && [element.attributes[@"property"] isEqualToString:@"og:url"]) {
                                ogUrl = element.attributes[@"content"];
                                NSLog(@"URL - %@", element.attributes[@"content"]);
                            }
                            else if (ogSiteName == nil && [element.attributes[@"property"] isEqualToString:@"og:site_name"]) {
                                ogSiteName = element.attributes[@"content"];
                                NSLog(@"Site Name - %@", element.attributes[@"content"]);
                            }
                            else if (ogTitle == nil && [element.attributes[@"property"] isEqualToString:@"og:title"]) {
                                ogTitle = element.attributes[@"content"];
                                NSLog(@"Title - %@", element.attributes[@"content"]);
                            }
                            else if (ogDesc == nil && [element.attributes[@"property"] isEqualToString:@"og:description"]) {
                                ogDesc = element.attributes[@"content"];
                                NSLog(@"Description - %@", element.attributes[@"content"]);
                            }
                            else if (ogImage == nil && [element.attributes[@"property"] isEqualToString:@"og:image"]) {
                                ogImage = element.attributes[@"content"];
                                NSLog(@"Image - %@", element.attributes[@"content"]);
                            }
                        }
                        else if (element.attributes[@"name"] != nil && ![element.attributes[@"name"] isKindOfClass:[NSNull class]]) {
                            if (twtSiteName == nil && [element.attributes[@"name"] isEqualToString:@"twitter:site"]) {
                                twtSiteName = element.attributes[@"content"];
                                NSLog(@"Site Name - %@", element.attributes[@"content"]);
                            }
                            else if (twtTitle == nil && [element.attributes[@"name"] isEqualToString:@"twitter:title"]) {
                                twtTitle = element.attributes[@"content"];
                                NSLog(@"Title - %@", element.attributes[@"content"]);
                            }
                            else if (twtDesc == nil && [element.attributes[@"name"] isEqualToString:@"twitter:description"]) {
                                twtDesc = element.attributes[@"content"];
                                NSLog(@"Description - %@", element.attributes[@"content"]);
                            }
                            else if (twtImage == nil && [element.attributes[@"name"] isEqualToString:@"twitter:image"]) {
                                twtImage = element.attributes[@"content"];
                                NSLog(@"Image - %@", element.attributes[@"content"]);
                            }
                            else if (desc == nil && [element.attributes[@"name"] isEqualToString:@"description"]) {
                                desc = element.attributes[@"content"];
                            }
                        }
                    }
                    else if ([element.tagName isEqualToString:@"title"]) {
                        if (element.childNodes.count > 0) {
                            if ([element.childNodes[0] isKindOfClass:[HTMLText class]]) {
                                title = ((HTMLText *)element.childNodes[0]).data;
                            }
                        }
                    }
                }
            }
            
            if (ogUrl != nil) {
                finalUrl = ogUrl;
            }
            else if (twtUrl != nil) {
                finalUrl = twtUrl;
            }
            else {
                finalUrl = [preViewUrl absoluteString];
            }
            
            if (ogSiteName != nil) {
                finalSiteName = ogSiteName;
            }
            else if (twtSiteName != nil) {
                finalSiteName = twtSiteName;
            }
            
            if (ogTitle != nil) {
                finalTitle = ogTitle;
            }
            else if (twtTitle != nil) {
                finalTitle = twtTitle;
            }
            else if (title != nil) {
                finalTitle = title;
            }
            
            if (ogDesc != nil) {
                finalDesc = ogDesc;
            }
            else if (twtDesc != nil) {
                finalDesc = twtDesc;
            }
            
            if (ogImage != nil) {
                finalImage = ogImage;
            }
            else if (twtImage != nil) {
                finalImage = twtImage;
            }
            
            if (!(finalSiteName == nil || finalTitle == nil || finalDesc == nil)) {
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                data[@"site_name"] = finalSiteName;
                data[@"title"] = finalTitle;
                data[@"description"] = finalDesc;
                if (finalImage != nil) {
                    data[@"image"] = finalImage;
                }
                
                if (finalUrl != nil) {
                    data[@"url"] = finalUrl;
                }
                
                NSError *err;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&err];
                NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:message];
                params.data = dataString;
                params.customType = @"url_preview";
                [self.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                    // Do nothing.
                    
                    if (error != nil) {
                        [self sendMessageWithReplacement:aTempModel];
                        
                        return;
                    }

                    [self.messageCollection appendMessage:userMessage];
                    [self.chattingView scrollToBottomWithForce:YES];
                }];
            }
            else {
                [self sendMessageWithReplacement:aTempModel];
            }
        }

        [session invalidateAndCancel];
    }] resume];
}

- (NSArray <NSString *> *)targetLanguages {
    return @[@"ar", @"de", @"fr", @"nl", @"ja", @"ko", @"pt", @"es", @"zh-CHS"];
}

#pragma mark - Message Manager
- (SBSMMessageCollection *)messageCollection {
    if (_messageCollection == nil) {
        _messageCollection = [self createMessageCollection];
    }
    return _messageCollection;
}

- (SBSMMessageCollection *)createMessageCollection {
    SBSMMessageFilter *filter = [SBSMMessageFilter filterWithMessageType:SBDMessageTypeFilterAll customType:nil senderUserIds:nil];
    SBSMMessageCollection *collection = [SBSMMessageCollection collectionWithChannel:self.channel filter:filter viewpointTimestamp:LONG_LONG_MAX];
    return collection;
}

#pragma mark - Message Collection
- (void)fetchPreviousMessages {
    if (![self isLoading]) {
        self.loading = YES;
        [self.messageCollection fetchInDirection:SBSMMessageDirectionPrevious completionHandler:^(SBDError * _Nullable error) {
            self.loading = NO;
        }];
    }
}

#pragma mark - Message Collection Delegate
- (void)collection:(SBSMMessageCollection *)collection didReceiveEvent:(SBSMMessageEventAction)action messages:(NSArray<SBDBaseMessage *> *)messages {
    self.chattingView.initialLoading = NO;
    if (self.messageCollection != collection || messages == nil || messages.count == 0) {
        return;
    }
    
    __block SBSMOperation *operation = [self.collectionQueue enqueue:^{
        SBSMVoidHandler handler = ^void() {
            [operation complete];
        };
        
        switch (action) {
            case SBSMMessageEventActionInsert: {
                [self.chattingView insertMessages:messages comparator:collection.comparator completionHandler:^{
                    handler();
                    
                    if ([Utils isTopViewController:self]) {
                        [self.channel markAsRead];
                    }
                }];
                break;
            }
            case SBSMMessageEventActionUpdate : {
                [self.chattingView updateMessages:messages completionHandler:handler];
                break;
            }
            case SBSMMessageEventActionRemove: {
                [self.chattingView removeMessages:messages completionHandler:handler];
                break;
            }
            case SBSMMessageEventActionClear: {
                [self.chattingView clearAllMessagesWithCompletionHandler:handler];
                break;
            }
            case SBSMMessageEventActionNone:
            default:
                break;
        }
    }];
}

#pragma mark - SBDChannelDelegate
- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender {
    if ([sender.channelUrl isEqualToString:self.channel.channelUrl]) {
        if (sender.getTypingMembers.count == 0) {
            [self.chattingView endTypingIndicator];
        }
        else {
            if (sender.getTypingMembers.count == 1) {
                [self.chattingView startTypingIndicator:[NSString stringWithFormat:@"%@ is typing...", sender.getTypingMembers[0].nickname]];
            }
            else {
                [self.chattingView startTypingIndicator:@"Several people are typing..."];
            }
        }
    }
}

// TODO: close from collection delegate
- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType {
    if (![channelUrl isEqualToString:self.channel.channelUrl]) {
        return;
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Channel has been deleted." message:@"This channel has been deleted. It will be closed." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self close];
    }];
    [vc addAction:closeAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - SendBird SDK
- (void)sendMessageWithReplacement:(OutgoingGeneralUrlPreviewTempModel * _Nonnull)replacement {
    SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:replacement.message];
    params.targetLanguages = self.targetLanguages;
    __block SBDUserMessage *previewMessage = [self.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        [self.chattingView scrollToBottomWithForce:YES];
        
        if (error != nil) {
            [self.messageCollection deleteMessage:previewMessage];
            return;
        }
        
        [self.messageCollection appendMessage:userMessage];
        previewMessage = nil;
    }];
    
    if (previewMessage.requestId != nil) {
        [self.messageCollection appendMessage:previewMessage];
    }
}

- (void)sendMessage {
    if (self.chattingView.messageTextView.text.length > 0) {
        [self.channel endTyping];
        NSString *message = [self.chattingView.messageTextView.text copy];
        self.chattingView.messageTextView.text = @"";
        
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (error == nil) {
            NSArray *matches = [detector matchesInString:message options:0 range:NSMakeRange(0, message.length)];
            NSURL *url = nil;
            for (NSTextCheckingResult *match in matches) {
                url = [match URL];
                break;
            }
            
            if (url != nil) {
                OutgoingGeneralUrlPreviewTempModel *tempModel = [[OutgoingGeneralUrlPreviewTempModel alloc] init];
                tempModel.createdAt = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
                tempModel.message = message;
                
                [self.chattingView insertMessages:@[tempModel] comparator:self.messageCollection.comparator completionHandler:^{
                    [self sendUrlPreview:url message:message tempModel:tempModel];
                }];
                
                return;
            }
        }
        
        self.chattingView.sendButton.enabled = NO;
        SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:message];
        params.targetLanguages = self.targetLanguages;
        __block SBDUserMessage *previewMessage = [self.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            [self.chattingView scrollToBottomWithForce:YES];
            
            if (error != nil) {
                [self.messageCollection deleteMessage:previewMessage];
                return;
            }
            
            [self.messageCollection appendMessage:userMessage];
            previewMessage = nil;
        }];
        
        if (previewMessage.requestId != nil) {
            [self.messageCollection appendMessage:previewMessage];
        }
        self.chattingView.sendButton.enabled = YES;
    }
}

- (void)selectFileAttachment {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
                mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
                mediaUI.mediaTypes = mediaTypes;
                [mediaUI setDelegate:self];
                self.refreshInViewDidAppear = NO;
                [self presentViewController:mediaUI animated:YES completion:nil];
            }
        }];
    }
    else {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
        mediaUI.mediaTypes = mediaTypes;
        [mediaUI setDelegate:self];
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
}

- (void)clickReconnect {
    if ([SBDMain getConnectState] != SBDWebSocketOpen && [SBDMain getConnectState] != SBDWebSocketConnecting) {
        [SBDMain reconnect];
    }
}

#pragma mark - ChattingViewDelegate
- (void)loadMoreMessage:(UIView *)view {
    [self fetchPreviousMessages];
}

- (void)startTyping:(UIView *)view {
    [self.channel startTyping];
}

- (void)endTyping:(UIView *)view {
    [self.channel endTyping];
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

#pragma mark - Message Delegate
- (void)clickProfileImage:(UITableViewCell *)viewCell user:(SBDUser *)user {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:user.nickname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *seeBlockUserAction = [UIAlertAction actionWithTitle:@"Block the user" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SBDMain blockUser:user completionHandler:^(SBDUser * _Nullable blockedUser, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"User blocked" message:[NSString stringWithFormat:@"%@ is blocked.", user.nickname] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
            });
        }];
        
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:seeBlockUserAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)clickMessage:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:closeAction];
    
    if ([self isUrlPreviewMessage:message]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)message;
        NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSURL *url = [NSURL URLWithString:previewData[@"url"]];
        [Application openURL:url];
    }
    else if ([self isBeingDeliveredMessage:message]) {
        NSString *title = @"Delete the message";
        UIAlertAction *deletingAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self requestDeleteMessage:message];
        }];
        [alert addAction:deletingAction];
        
        if ([message isKindOfClass:[SBDUserMessage class]]) {
            SBDUserMessage *userMessage = (SBDUserMessage *)message;
            NSArray <UIAlertAction *> *actions = [self actionsOpeningUrlFromString:userMessage.message];
            for (UIAlertAction *action in actions) {
                [alert addAction:action];
            }
        }
    }
    else if ([self isPlayableTypeOfMessage:message]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        NSString *url = fileMessage.url;
        NSURL *mediaUrl = [NSURL URLWithString:url];
        AVPlayer *player = [[AVPlayer alloc] initWithURL:mediaUrl];
        AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
        vc.player = player;
        [self presentViewController:vc animated:YES completion:^{
            [player play];
        }];
        
        return;
    }
    else if ([self isImageTypeOfMessage:message]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        NSString *url = fileMessage.url;
        [self presentPhotoWithUrl:[NSURL URLWithString:url]];
        
        return;
    }
    else if ([message isKindOfClass:[SBDAdminMessage class]]) {
        return;
    }
    
    if (alert.actions.count > 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (BOOL)isUrlPreviewMessage:(SBDBaseMessage *)message {
    if ([message isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)message;
        return [userMessage.customType isEqualToString:@"url_preview"];
    }
    else return NO;
}

- (NSArray <UIAlertAction *> *)actionsOpeningUrlFromString:(NSString *)string {
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error != nil) {
        return @[];
    }
    
    NSRange range = NSMakeRange(0, string.length);
    NSArray *matches = [detector matchesInString:string options:0 range:range];
    NSMutableArray <UIAlertAction *> *actions = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSURL *url = [match URL];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[url relativeString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Application openURL:url];
        }];
        [actions addObject:action];
    }
    return [actions copy];
}

- (BOOL)isBeingDeliveredMessage:(SBDBaseMessage *)message {
    SBDUser *sender = [message valueForKey:@"sender"];
    NSString *requestId = [message valueForKey:@"requestId"];
    if (sender != nil && [sender.userId isEqualToString:[SBDMain getCurrentUser].userId] &&
        requestId != nil) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPlayableTypeOfMessage:(SBDBaseMessage *)message {
    if ([message isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        NSString *type = fileMessage.type;
        if ([type hasPrefix:@"image"]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isImageTypeOfMessage:(SBDBaseMessage *)message {
    if ([message isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)message;
        NSString *type = fileMessage.type;
        if ([type hasPrefix:@"video"] || [type hasPrefix:@"audio"]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)requestDeleteMessage:(SBDBaseMessage *)message {
    [self.channel deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
            
            return;
        }
        
        [self.messageCollection deleteMessage:message];
    }];
}

- (void)presentPhotoViewController:(NYTPhotosViewController *)photosViewController {
    photosViewController.rightBarButtonItems = nil;
    photosViewController.rightBarButtonItem = nil;
    
    UIBarButtonItem *negativeLeftSpacerForImageViewerLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacerForImageViewerLoading.width = -2;
    
    UIBarButtonItem *leftCloseItemForImageViewerLoading = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(closeImageViewer)];
    
    photosViewController.leftBarButtonItems = @[negativeLeftSpacerForImageViewerLoading, leftCloseItemForImageViewerLoading];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:photosViewController animated:YES completion:^{
            [self hideImageViewerLoading];
        }];
    });
}

- (void)presentPhotoWithUrl:(NSURL *)url {
    [self showImageViewerLoading];
    ChatImage *photo = [[ChatImage alloc] init];
    NSData *cachedData = [FLAnimatedImageView cachedImageForURL:url];
    if (cachedData != nil) {
        photo.imageData = cachedData;
        
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
        self.photosViewController = photosViewController;
        [self presentPhotoViewController:photosViewController];
    }
    else {
        NSURLSession *session = [NSURLSession sharedSession];
        __block NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                [self hideImageViewerLoading];
                return;
            }
            
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            if ([resp statusCode] >= 200 && [resp statusCode] < 300) {
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                [[AppDelegate imageCache] storeCachedResponse:cachedResponse forRequest:request];
                
                ChatImage *photo = [[ChatImage alloc] init];
                photo.imageData = data;
                
                NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
                self.photosViewController = photosViewController;
                [self presentPhotoViewController:photosViewController];
            }
            else {
                [self hideImageViewerLoading];
            }
        }] resume];
    }
}

- (void)clickResend:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Resend Message" message:@"Do you want to resend the message?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *resendAction = [UIAlertAction actionWithTitle:@"Resend" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([message isKindOfClass:[SBDUserMessage class]]) {
            SBDUserMessage *resendableUserMessage = (SBDUserMessage *)message;
            NSArray<NSString *> *targetLanguages = nil;
            if (resendableUserMessage.translations != nil) {
                targetLanguages = [resendableUserMessage.translations allKeys];
            }
            
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            if (error == nil) {
                NSArray *matches = [detector matchesInString:resendableUserMessage.message options:0 range:NSMakeRange(0, resendableUserMessage.message.length)];
                NSURL *url = nil;
                for (NSTextCheckingResult *match in matches) {
                    url = [match URL];
                    break;
                }
                
                if (url != nil) {
                    OutgoingGeneralUrlPreviewTempModel *tempModel = [[OutgoingGeneralUrlPreviewTempModel alloc] init];
                    tempModel.createdAt = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
                    tempModel.message = resendableUserMessage.message;
                    
                    // TODO: check resending
                    // Send preview;
                    [self sendUrlPreview:url message:resendableUserMessage.message tempModel:tempModel];
                    
                    return;
                }
            }

            SBDUserMessageParams *params = [[SBDUserMessageParams alloc] initWithMessage:resendableUserMessage.message];
            params.data = resendableUserMessage.data;
            params.customType = resendableUserMessage.customType;
            params.targetLanguages = targetLanguages;
            __block SBDUserMessage *previewMessage = [self.channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                [self.chattingView scrollToBottomWithForce:YES];
                if (error != nil) {
                    [self.messageCollection deleteMessage:previewMessage];
                    return;
                }
                
                [self.messageCollection appendMessage:userMessage];
                previewMessage = nil;
            }];
            
            if (previewMessage.requestId != nil) {
                [self.messageCollection appendMessage:previewMessage];
            }
        }
        else if ([message isKindOfClass:[SBDFileMessage class]]) {
            __block SBDFileMessage *resendableFileMessage = (SBDFileMessage *)message;
            
            NSMutableArray<SBDThumbnailSize *> *thumbnailsSizes = [[NSMutableArray alloc] init];
            for (SBDThumbnail *thumbnail in resendableFileMessage.thumbnails) {
                [thumbnailsSizes addObject:[SBDThumbnailSize makeWithMaxCGSize:thumbnail.maxSize]];
            }
            
            NSData *fileData = (NSData *)self.chattingView.resendableFileData[resendableFileMessage.requestId][@"data"];
            SBDFileMessageParams *params = [[SBDFileMessageParams alloc] initWithFile:fileData];
            params.fileName = resendableFileMessage.name;
            params.mimeType = resendableFileMessage.type;
            params.fileSize = resendableFileMessage.size;
            params.thumbnailSizes = thumbnailsSizes;
            params.data = resendableFileMessage.data;
            params.customType = resendableFileMessage.customType;
            __block SBDFileMessage *previewMessage = [self.channel sendFileMessageWithParams:params completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                if (error != nil) {
                    [self.messageCollection deleteMessage:previewMessage];
                    self.chattingView.resendableFileData[fileMessage.requestId] = self.chattingView.preSendFileData[fileMessage.requestId];
                    [self.chattingView.preSendFileData removeObjectForKey:fileMessage.requestId];
                    
                    return;
                }
                
                [self.messageCollection appendMessage:fileMessage];
                previewMessage = nil;
            }];
            
            if (previewMessage.requestId != nil) {
                [self.messageCollection appendMessage:previewMessage];
                self.chattingView.preSendFileData[previewMessage.requestId] = self.chattingView.resendableFileData[resendableFileMessage.requestId];
                [self.chattingView.resendableFileData removeObjectForKey:resendableFileMessage.requestId];
            }
        }
    }];
    
    [vc addAction:closeAction];
    [vc addAction:resendAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)clickDelete:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Delete Message" message:@"Do you want to delete the message?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *requestId = nil;
        if ([message isKindOfClass:[SBDUserMessage class]]) {
            requestId = ((SBDUserMessage *)message).requestId;
        }
        else if ([message isKindOfClass:[SBDFileMessage class]]) {
            requestId = ((SBDFileMessage *)message).requestId;
        }
        
        if (requestId == nil) {
            return;
        }
        
        [self.chattingView.resendableFileData removeObjectForKey:requestId];
        [self.messageCollection deleteMessage:message];
    }];
    
    [vc addAction:closeAction];
    [vc addAction:deleteAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)sendFileMessageWithFileData:(NSData *)fileData fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
    SBDFileMessageParams *params = [[SBDFileMessageParams alloc] initWithFile:fileData];
    params.fileName = fileName;
    params.mimeType = mimeType;
    params.fileSize = fileData.length;
    params.thumbnailSizes = @[thumbnailSize];
    __weak GroupChannelChattingViewController *weakSelf = self;
    NSDictionary *fileDataDict = @{@"data": params.file, @"type": params.mimeType};
    __block SBDFileMessage *previewMessage = [self.channel sendFileMessageWithParams:params completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
        GroupChannelChattingViewController *strongSelf = weakSelf;
        [strongSelf.messageCollection deleteMessage:previewMessage];
        [strongSelf.chattingView scrollToBottomWithForce:YES];
        previewMessage = nil;
        
        if (error != nil) {
            strongSelf.chattingView.resendableFileData[previewMessage.requestId] = fileDataDict;
            return;
        }
        
        if (fileMessage != nil) {
            [strongSelf.chattingView.resendableFileData removeObjectForKey:fileMessage.requestId];
            [strongSelf.messageCollection appendMessage:fileMessage];
        }
    }];
    
    if (previewMessage.requestId != nil) {
        self.chattingView.preSendFileData[previewMessage.requestId] = fileDataDict;
        [self.messageCollection appendMessage:previewMessage];
    }
}

- (NSString *)infersMimeTypeFromFileUrl:(NSURL *)url {
    NSString *fileName = url.lastPathComponent;
    NSString *ext = [fileName pathExtension];
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    return mimeType;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([Utils isKindOfImage:mediaType]) {
            NSURL *imageUrl = info[UIImagePickerControllerImageURL];
            NSString *imageName = imageUrl.lastPathComponent;
            NSString *mimeType = [self infersMimeTypeFromFileUrl:imageUrl];
            PHAsset *asset = info[UIImagePickerControllerPHAsset];
            
            if ([mimeType isEqualToString:@"image/gif"]) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                options.networkAccessAllowed = NO;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSNumber *isError = [info objectForKey:PHImageErrorKey];
                    NSNumber *isCloud = [info objectForKey:PHImageResultIsInCloudKey];
                    if ([isError boolValue] || [isCloud boolValue] || !imageData) {
                        // fail
                        return;
                    }
                    
                    // success, data is in imageData
                    /***********************************/
                    /* Thumbnail is a premium feature. */
                    /***********************************/
                    [self sendFileMessageWithFileData:imageData fileName:imageName mimeType:mimeType];
                }];
            }
            else {
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (result == nil) {
                        return;
                    }
                    
                    // success, data is in imageData
                    /***********************************/
                    /* Thumbnail is a premium feature. */
                    /***********************************/
                    NSData *imageData = UIImageJPEGRepresentation(result, 1.0);
                    [self sendFileMessageWithFileData:imageData fileName:imageName mimeType:mimeType];
                }];
            }
        }
        else if ([Utils isKindOfVideo:mediaType]) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            NSString *videoName = videoURL.lastPathComponent;
            NSString *mimeType = [self infersMimeTypeFromFileUrl:videoURL];
            
            // success, data is in imageData
            /***********************************/
            /* Thumbnail is a premium feature. */
            /***********************************/
            [self sendFileMessageWithFileData:videoFileData fileName:videoName mimeType:mimeType];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)showImageViewerLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageViewerLoadingView.hidden = NO;
        self.imageViewerLoadingIndicator.hidden = NO;
        [self.imageViewerLoadingIndicator startAnimating];
    });
}

- (void)hideImageViewerLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageViewerLoadingView.hidden = YES;
        self.imageViewerLoadingIndicator.hidden = YES;
        [self.imageViewerLoadingIndicator stopAnimating];
    });
}

- (void)closeImageViewer {
    if (self.photosViewController != nil) {
        [self.photosViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end





