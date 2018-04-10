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
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <HTMLKit/HTMLKit.h>

#import "AppDelegate.h"
#import "GroupChannelChattingViewController.h"
#import "MemberListViewController.h"
#import "BlockedUserListViewController.h"
#import "NSBundle+SendBird.h"
#import "Utils.h"
#import "ChatImage.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "CreateGroupChannelUserListViewController.h"

@interface GroupChannelChattingViewController ()

@property (weak, nonatomic) IBOutlet ChattingView *chattingView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) NSString *delegateIdentifier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet UIView *imageViewerLoadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageViewerLoadingIndicator;
@property (weak, nonatomic) IBOutlet UINavigationItem *imageViewerLoadingViewNavItem;

@property (atomic) BOOL hasNext;
@property (atomic) BOOL refreshInViewDidAppear;

@property (atomic) BOOL isLoading;
@property (atomic) BOOL keyboardShown;

@property (strong, nonatomic) NYTPhotosViewController *photosViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeight;

@property (atomic) long long minMessageTimestamp;

@property (strong, nonatomic) NSArray<SBDBaseMessage *> *dumpedMessages;
@property (atomic) BOOL cachedMessage;

@end

@implementation GroupChannelChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 64)];
    titleView.attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:nil];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    
    UIBarButtonItem *negativeLeftSpacerForImageViewerLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacerForImageViewerLoading.width = -2;
    
    UIBarButtonItem *leftCloseItemForImageViewerLoading = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(hideImageViewerLoading)];
    
    self.imageViewerLoadingViewNavItem.leftBarButtonItems = @[negativeLeftSpacerForImageViewerLoading, leftCloseItemForImageViewerLoading];

    self.delegateIdentifier = self.description;
    [SBDMain addChannelDelegate:self identifier:self.delegateIdentifier];
    [SBDMain addConnectionDelegate:self identifier:self.delegateIdentifier];
    
    self.hasNext = YES;
    self.refreshInViewDidAppear = YES;
    self.isLoading = NO;
    
    [self.chattingView.fileAttachButton addTarget:self action:@selector(sendFileMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.chattingView.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    self.dumpedMessages = [Utils loadMessagesInChannel:self.channel.channelUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.refreshInViewDidAppear) {
        self.minMessageTimestamp = LLONG_MAX;
        [self.chattingView configureChattingViewWithChannel:self.channel];
        self.chattingView.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.refreshInViewDidAppear) {
        if (self.dumpedMessages.count > 0) {
            [self.chattingView.messages addObjectsFromArray:self.dumpedMessages];
            
            [self.chattingView.chattingTableView reloadData];
            [self.chattingView.chattingTableView layoutIfNeeded];
            
            CGFloat viewHeight = [[UIScreen mainScreen] bounds].size.height - self.navigationBarHeight.constant - self.chattingView.inputContainerViewHeight.constant - 10;
            CGSize contentSize = self.chattingView.chattingTableView.contentSize;
            
            if (contentSize.height > viewHeight) {
                CGPoint newContentOffset = CGPointMake(0, contentSize.height - viewHeight);
                [self.chattingView.chattingTableView setContentOffset:newContentOffset animated:NO];
            }
            self.cachedMessage = YES;
            [self loadPreviousMessage:YES];
            
            return;
        }
        else {
            self.cachedMessage = NO;
            self.minMessageTimestamp = LLONG_MAX;
            [self loadPreviousMessage:YES];
        }
    }
    
    self.refreshInViewDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Utils dumpMessages:self.chattingView.messages resendableMessages:self.chattingView.resendableMessages resendableFileData:self.chattingView.resendableFileData preSendMessages:self.chattingView.preSendMessages channelUrl:self.channel.channelUrl];
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

- (void)applicationWillTerminate:(NSNotification *)notification {
    [Utils dumpMessages:self.chattingView.messages resendableMessages:self.chattingView.resendableMessages resendableFileData:self.chattingView.resendableFileData preSendMessages:self.chattingView.preSendMessages channelUrl:self.channel.channelUrl];
}

- (void)close {
    [SBDMain removeChannelDelegateForIdentifier:self.description];
    [SBDMain removeConnectionDelegateForIdentifier:self.description];
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

    UIAlertAction *inviteUserListAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"InviteUserButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CreateGroupChannelUserListViewController *vc = [[CreateGroupChannelUserListViewController alloc] init];
            vc.userSelectionMode = 1;
            vc.groupChannel = self.channel;
            self.refreshInViewDidAppear = NO;
            [self presentViewController:vc animated:NO completion:nil];
        });
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:seeMemberListAction];
    [vc addAction:inviteUserListAction];
    [vc addAction:closeAction];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loadPreviousMessage:(BOOL)initial {
    long long timestamp = 0;
    if (initial) {
        self.hasNext = YES;
        timestamp = LLONG_MAX;
    }
    else {
        timestamp = self.minMessageTimestamp;
    }
    
    if (self.hasNext == NO) {
        return;
    }

    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.channel getPreviousMessagesByTimestamp:timestamp limit:30 reverse:!initial messageType:SBDMessageTypeFilterAll customType:@"" completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
        if (error != nil) {
            self.isLoading = NO;
            
            return;
        }
        
        self.cachedMessage = NO;
        
        if (messages.count == 0) {
            self.hasNext = NO;
        }
        
        if (initial) {
            [self.chattingView.messages removeAllObjects];
            
            for (SBDBaseMessage *message in messages) {
                [self.chattingView.messages addObject:message];
                
                if (self.minMessageTimestamp > message.createdAt) {
                    self.minMessageTimestamp = message.createdAt;
                }
            }
            
            NSArray *resendableMessagesKeys = [self.chattingView.resendableMessages allKeys];
            for (NSString *key in resendableMessagesKeys) {
                [self.chattingView.messages addObject:self.chattingView.resendableMessages[key]];
            }
            
            NSArray *preSendMessagesKeys = [self.chattingView.preSendMessages allKeys];
            for (NSString *key in preSendMessagesKeys) {
                [self.chattingView.messages addObject:self.chattingView.preSendMessages[key]];
            }
            
            [self.channel markAsRead];
            
            self.chattingView.initialLoading = YES;
            
            if (messages.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView.chattingTableView reloadData];
                    [self.chattingView.chattingTableView layoutIfNeeded];
                    
                    CGFloat viewHeight;
                    if (self.keyboardShown) {
                        viewHeight = self.chattingView.chattingTableView.frame.size.height - 10;
                    }
                    else {
                        viewHeight = [[UIScreen mainScreen] bounds].size.height - self.navigationBarHeight.constant - self.chattingView.inputContainerViewHeight.constant - 10;
                    }
                    
                    CGSize contentSize = self.chattingView.chattingTableView.contentSize;
                    
                    if (contentSize.height > viewHeight) {
                        CGPoint newContentOffset = CGPointMake(0, contentSize.height - viewHeight);
                        [self.chattingView.chattingTableView setContentOffset:newContentOffset animated:NO];
                    }
                });
            }
            
            self.chattingView.initialLoading = NO;
            self.isLoading = NO;
        }
        else {
            if (messages.count > 0) {
                for (SBDBaseMessage *message in messages) {
                    [self.chattingView.messages insertObject:message atIndex:0];
                    
                    if (self.minMessageTimestamp > message.createdAt) {
                        self.minMessageTimestamp = message.createdAt;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize contentSizeBefore = self.chattingView.chattingTableView.contentSize;
                    
                    [self.chattingView.chattingTableView reloadData];
                    [self.chattingView.chattingTableView layoutIfNeeded];
                    
                    CGSize contentSizeAfter = self.chattingView.chattingTableView.contentSize;
                    
                    CGPoint newContentOffset = CGPointMake(0, contentSizeAfter.height - contentSizeBefore.height);
                    [self.chattingView.chattingTableView setContentOffset:newContentOffset animated:NO];
                });
            }

            self.isLoading = NO;
        }
    }];
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
                
                [self.channel sendUserMessage:message data:dataString customType:@"url_preview" completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
                    // Do nothing.
                    
                    if (error != nil) {
                        [self sendMessageWithReplacement:aTempModel];
                        
                        return;
                    }

                    NSUInteger tempIndex = [self.chattingView.messages indexOfObject:aTempModel];
                    if (tempIndex != NSNotFound) {
                        [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:aTempModel] withObject:userMessage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chattingView.chattingTableView reloadData];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.chattingView scrollToBottomWithForce:YES];
                            });
                        });
                    }
                }];
            }
            else {
                [self sendMessageWithReplacement:aTempModel];
            }
        }

        [session invalidateAndCancel];
    }] resume];
}

- (void)sendMessageWithReplacement:(OutgoingGeneralUrlPreviewTempModel * _Nonnull)replacement {
    SBDUserMessage *preSendMessage = [self.channel sendUserMessage:replacement.message data:@"" customType:@"" targetLanguages:@[@"ar", @"de", @"fr", @"nl", @"ja", @"ko", @"pt", @"es", @"zh-CHS"] completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
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
    [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:replacement] withObject:preSendMessage];
    self.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chattingView.chattingTableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView scrollToBottomWithForce:YES];
        });
    });
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
                
                [self.chattingView.messages addObject:tempModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView.chattingTableView reloadData];
                    [self.chattingView scrollToBottomWithForce:YES];
                    
                    // Send preview;
                    [self sendUrlPreview:url message:message tempModel:tempModel];
                });

                return;
            }
        }
        
        self.chattingView.sendButton.enabled = NO;
        SBDUserMessage *preSendMessage = [self.channel sendUserMessage:message data:@"" customType:@"" targetLanguages:@[@"ar", @"de", @"fr", @"nl", @"ja", @"ko", @"pt", @"es", @"zh-CHS"] completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
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
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:[self.chattingView.messages indexOfObject:preSendMessage] inSection:0];
                [self.chattingView.chattingTableView beginUpdates];
                if (preSendMessage != nil) {
                    [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:preSendMessage] withObject:userMessage];
                }
                [UIView setAnimationsEnabled:NO];

                [self.chattingView.chattingTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
                [UIView setAnimationsEnabled:YES];
                [self.chattingView.chattingTableView endUpdates];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chattingView scrollToBottomWithForce:YES];
                });
            });
        }];
        
        self.chattingView.preSendMessages[preSendMessage.requestId] = preSendMessage;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.chattingView.preSendMessages[preSendMessage.requestId] == nil) {
                return;
            }
            [self.chattingView.chattingTableView beginUpdates];
            [self.chattingView.messages addObject:preSendMessage];

            [UIView setAnimationsEnabled:NO];

            [self.chattingView.chattingTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.chattingView.messages indexOfObject:preSendMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

            [UIView setAnimationsEnabled:YES];
            [self.chattingView.chattingTableView endUpdates];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chattingView scrollToBottomWithForce:YES];
                self.chattingView.sendButton.enabled = YES;
            });
        });
    }
}

- (void)sendFileMessage {
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
        self.refreshInViewDidAppear = NO;
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
}

- (void)clickReconnect {
    if ([SBDMain getConnectState] != SBDWebSocketOpen && [SBDMain getConnectState] != SBDWebSocketConnecting) {
        [SBDMain reconnect];
    }
}

#pragma mark - SBDConnectionDelegate

- (void)didStartReconnection {
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:[NSBundle sbLocalizedStringForKey:@"ReconnectingSubTitle"]];
        });
    }
}

- (void)didSucceedReconnection {
    [self loadPreviousMessage:YES];
    
    [self.channel refreshWithCompletionHandler:^(SBDError * _Nullable error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
                    ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:[NSBundle sbLocalizedStringForKey:@"ReconnectedSubTitle"]];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
                        ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:nil];
                    }
                });
            });
        }
    }];
}

- (void)didFailReconnection {
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:[NSBundle sbLocalizedStringForKey:@"ReconnectionFailedSubTitle"]];
        });
    }
}

#pragma mark - SBDChannelDelegate

- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message {
    if (sender == self.channel) {
        [self.channel markAsRead];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView setAnimationsEnabled:NO];
            [self.chattingView.messages addObject:message];
            [self.chattingView.chattingTableView reloadData];
            [UIView setAnimationsEnabled:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chattingView scrollToBottomWithForce:NO];
            });
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
    if (sender == self.channel) {
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
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user {
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:nil];
        });
    }
}

- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user {
    if (self.navItem.titleView != nil && [self.navItem.titleView isKindOfClass:[UILabel class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UILabel *)self.navItem.titleView).attributedText = [Utils generateNavigationTitle:[NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"GroupChannelTitle"], self.channel.memberCount] subTitle:nil];
        });
    }
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
    if (self.cachedMessage) {
        return;
    }
    
    [self loadPreviousMessage:NO];
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
        __block SBDBaseMessage *baseMessage = message;
        if ([baseMessage isKindOfClass:[SBDUserMessage class]]) {
            SBDUserMessage *userMessage = (SBDUserMessage *)baseMessage;
            if (userMessage.customType != nil && [userMessage.customType isEqualToString:@"url_preview"]) {
                NSData *data = [userMessage.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSURL *url = [NSURL URLWithString:previewData[@"url"]];
                [[UIApplication sharedApplication] openURL:url];
            }
            else {
                SBDUser *sender = ((SBDUserMessage *)baseMessage).sender;
                if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId] && self.chattingView.preSendMessages[((SBDUserMessage *)baseMessage).requestId] == nil) {
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
        }
        else if ([baseMessage isKindOfClass:[SBDFileMessage class]]) {
            SBDFileMessage *fileMessage = (SBDFileMessage *)baseMessage;
            SBDUser *sender = ((SBDFileMessage *)baseMessage).sender;
            __block NSString *type = fileMessage.type;
            __block NSString *url = fileMessage.url;
            
            if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId] && self.chattingView.preSendMessages[fileMessage.requestId] == nil) {
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
                NSURL *videoUrl = [NSURL URLWithString:url];
                AVPlayer *player = [[AVPlayer alloc] initWithURL:videoUrl];
                AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                vc.player = player;
                self.refreshInViewDidAppear = NO;
                [self presentViewController:vc animated:YES completion:^{
                    [player play];
                }];
                
                return;
            }
            else if ([type hasPrefix:@"audio"]) {
                NSURL *audioUrl = [NSURL URLWithString:url];
                AVPlayer *player = [[AVPlayer alloc] initWithURL:audioUrl];
                AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                vc.player = player;
                self.refreshInViewDidAppear = NO;
                [self presentViewController:vc animated:YES completion:^{
                    [player play];
                }];
                
                return;
            }
            else if ([type hasPrefix:@"image"]) {
                [self showImageViewerLoading];
                ChatImage *photo = [[ChatImage alloc] init];
                NSData *cachedData = [FLAnimatedImageView cachedImageForURL:[NSURL URLWithString:url]];
                if (cachedData != nil) {
                    photo.imageData = cachedData;
                    
                    self.photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.photosViewController.rightBarButtonItems = nil;
                        self.photosViewController.rightBarButtonItem = nil;
                        
                        UIBarButtonItem *negativeLeftSpacerForImageViewerLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                        negativeLeftSpacerForImageViewerLoading.width = -2;
                        
                        UIBarButtonItem *leftCloseItemForImageViewerLoading = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(closeImageViewer)];
                        
                        self.photosViewController.leftBarButtonItems = @[negativeLeftSpacerForImageViewerLoading, leftCloseItemForImageViewerLoading];
                    
                    
                        [self presentViewController:self.photosViewController animated:YES completion:^{
                            [self hideImageViewerLoading];
                        }];
                    });
                }
                else {
                    NSURLSession *session = [NSURLSession sharedSession];
                    __block NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
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
                            
                            self.photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.photosViewController.rightBarButtonItems = nil;
                                self.photosViewController.rightBarButtonItem = nil;
                                
                                UIBarButtonItem *negativeLeftSpacerForImageViewerLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                                negativeLeftSpacerForImageViewerLoading.width = -2;
                                
                                UIBarButtonItem *leftCloseItemForImageViewerLoading = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(closeImageViewer)];
                                
                                self.photosViewController.leftBarButtonItems = @[negativeLeftSpacerForImageViewerLoading, leftCloseItemForImageViewerLoading];
                            
                            
                                [self presentViewController:self.photosViewController animated:NO completion:^{
                                    [self hideImageViewerLoading];
                                }];
                            });
                        }
                        else {
                            [self hideImageViewerLoading];
                        }
                    }] resume];
                }
                
                return;
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
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ResendFailedMessageTitle"] message:[NSBundle sbLocalizedStringForKey:@"ResendFailedMessageDescription"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *resendAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"ResendFailedMessageButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
                    
                    [self.chattingView.messages replaceObjectAtIndex:[self.chattingView.messages indexOfObject:resendableUserMessage] withObject:tempModel];
                    [self.chattingView.resendableMessages removeObjectForKey:resendableUserMessage.requestId];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.chattingView.chattingTableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chattingView scrollToBottomWithForce:YES];
                        });
                    });
                    
                    // Send preview;
                    [self sendUrlPreview:url message:resendableUserMessage.message tempModel:tempModel];
                    
                    return;
                }
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
            [self.chattingView.resendableMessages removeObjectForKey:resendableUserMessage.requestId];
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
            __block SBDFileMessage *preSendMessage = [self.channel sendFileMessageWithBinaryData:(NSData *)self.chattingView.resendableFileData[resendableFileMessage.requestId][@"data"] filename:resendableFileMessage.name type:resendableFileMessage.type size:resendableFileMessage.size thumbnailSizes:thumbnailsSizes data:resendableFileMessage.data customType:resendableFileMessage.customType progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    SBDFileMessage *preSendMessage = (SBDFileMessage *)self.chattingView.preSendMessages[fileMessage.requestId];
                    [self.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
                    
                    if (error != nil) {
                        self.chattingView.resendableMessages[fileMessage.requestId] = fileMessage;
                        self.chattingView.resendableFileData[fileMessage.requestId] = self.chattingView.preSendFileData[fileMessage.requestId];
                        [self.chattingView.preSendFileData removeObjectForKey:fileMessage.requestId];
                        [self.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
                        [self.chattingView.chattingTableView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.chattingView scrollToBottomWithForce:YES];
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
            [self.chattingView.resendableMessages removeObjectForKey:resendableFileMessage.requestId];
            [self.chattingView.resendableFileData removeObjectForKey:resendableFileMessage.requestId];
            [self.chattingView.chattingTableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chattingView scrollToBottomWithForce:YES];
            });
        }
    }];
    
    [vc addAction:closeAction];
    [vc addAction:resendAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)clickDelete:(UIView *)view message:(SBDBaseMessage *)message {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"DeleteFailedMessageTitle"] message:[NSBundle sbLocalizedStringForKey:@"DeleteFailedMessageDescription"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"DeleteFailedMessageButton"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *requestId = nil;
        if ([message isKindOfClass:[SBDUserMessage class]]) {
            requestId = ((SBDUserMessage *)message).requestId;
        }
        else if ([message isKindOfClass:[SBDFileMessage class]]) {
            requestId = ((SBDFileMessage *)message).requestId;
        }
        [self.chattingView.resendableFileData removeObjectForKey:requestId];
        [self.chattingView.resendableMessages removeObjectForKey:requestId];
        [self.chattingView.messages removeObject:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chattingView.chattingTableView reloadData];
        });
    }];
    
    [vc addAction:closeAction];
    [vc addAction:deleteAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak GroupChannelChattingViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        GroupChannelChattingViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            NSString *imageName = [imagePath lastPathComponent];

            NSString *ext = [imageName pathExtension];
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
            NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);

            PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[imagePath] options:nil] lastObject];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = NO;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            
            if ([mimeType isEqualToString:@"image/gif"]) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSNumber *isError = [info objectForKey:PHImageErrorKey];
                    NSNumber *isCloud = [info objectForKey:PHImageResultIsInCloudKey];
                    if ([isError boolValue] || [isCloud boolValue] || !imageData) {
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
                                    
                                    return;
                                }
                                
                                if (fileMessage != nil) {
                                    [strongSelf.chattingView.resendableMessages removeObjectForKey:fileMessage.requestId];
                                    [strongSelf.chattingView.resendableFileData removeObjectForKey:fileMessage.requestId];
                                    [strongSelf.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
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
            else {
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (result != nil) {
                        // success, data is in imageData
                        /***********************************/
                        /* Thumbnail is a premium feature. */
                        /***********************************/
                        NSData *imageData = UIImageJPEGRepresentation(result, 1.0);
                        
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
                                    
                                    return;
                                }
                                
                                if (fileMessage != nil) {
                                    [strongSelf.chattingView.resendableMessages removeObjectForKey:fileMessage.requestId];
                                    [strongSelf.chattingView.resendableFileData removeObjectForKey:fileMessage.requestId];
                                    [strongSelf.chattingView.preSendMessages removeObjectForKey:fileMessage.requestId];
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
        }
        else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSData *videoFileData = [NSData dataWithContentsOfURL:videoURL];
            NSString *videoName = [videoURL lastPathComponent];

            NSString *ext = [videoName pathExtension];
            NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)ext, NULL);
            NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
            
            // success, data is in imageData
            /***********************************/
            /* Thumbnail is a premium feature. */
            /***********************************/
            SBDThumbnailSize *thumbnailSize = [SBDThumbnailSize makeWithMaxWidth:320.0 maxHeight:320.0];
            
            SBDFileMessage *preSendMessage = [strongSelf.channel sendFileMessageWithBinaryData:videoFileData filename:videoName type:mimeType size:videoFileData.length thumbnailSizes:@[thumbnailSize] data:@"" customType:@"" progressHandler:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
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
