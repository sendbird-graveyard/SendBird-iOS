//
//  ChattingView.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "ChattingView.h"
#import "IncomingUserMessageTableViewCell.h"
#import "OutgoingUserMessageTableViewCell.h"
#import "NeutralMessageTableViewCell.h"
#import "IncomingFileMessageTableViewCell.h"
#import "OutgoingImageFileMessageTableViewCell.h"
#import "OutgoingFileMessageTableViewCell.h"
#import "IncomingImageFileMessageTableViewCell.h"
#import "IncomingVideoFileMessageTableViewCell.h"
#import "OutgoingVideoFileMessageTableViewCell.h"
#import "IncomingGeneralUrlPreviewMessageTableViewCell.h"
#import "OutgoingGeneralUrlPreviewMessageTableViewCell.h"
#import "OutgoingGeneralUrlPreviewTempMessageTableViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "Utils+View.h"

@interface ChattingView()

@property (strong, nonatomic) SBDBaseChannel *channel;
    
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typingIndicatorContainerViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *typingIndicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *typingIndicatorLabel;
@property (weak, nonatomic) IBOutlet UIView *typingIndicatorContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typingIndicatorImageHeight;

@property (strong, nonatomic) IncomingUserMessageTableViewCell *incomingUserMessageSizingTableViewCell;
@property (strong, nonatomic) OutgoingUserMessageTableViewCell *outgoingUserMessageSizingTableViewCell;
@property (strong, nonatomic) NeutralMessageTableViewCell *neutralMessageSizingTableViewCell;
@property (strong, nonatomic) IncomingFileMessageTableViewCell *incomingFileMessageSizingTableViewCell;
@property (strong, nonatomic) OutgoingImageFileMessageTableViewCell *outgoingImageFileMessageSizingTableViewCell;
@property (strong, nonatomic) OutgoingFileMessageTableViewCell *outgoingFileMessageSizingTableViewCell;
@property (strong, nonatomic) IncomingImageFileMessageTableViewCell *incomingImageFileMessageSizingTableViewCell;
@property (strong, nonatomic) IncomingVideoFileMessageTableViewCell *incomingVideoFileMessageSizingTableViewCell;
@property (strong, nonatomic) OutgoingVideoFileMessageTableViewCell *outgoingVideoFileMessageSizingTableViewCell;
@property (strong, nonatomic) IncomingGeneralUrlPreviewMessageTableViewCell *incomingGeneralUrlPreviewMessageTableViewCell;
@property (strong, nonatomic) OutgoingGeneralUrlPreviewMessageTableViewCell *outgoingGeneralUrlPreviewMessageTableViewCell;
@property (strong, nonatomic) OutgoingGeneralUrlPreviewTempMessageTableViewCell *outgoingGeneralUrlPreviewTempMessageTableViewCell;

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (atomic) CGFloat lastMessageHeight;
@property (atomic) BOOL scrollLock;

@property (atomic) CGPoint lastOffset;
@property (atomic) NSTimeInterval lastOffsetCapture;
@property (atomic) BOOL isScrollingFast;

@property (strong, nonatomic, nonnull) SBSMOperationQueue *tableViewQueue;

@end

@implementation ChattingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self.chattingTableView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(15.5, 0, 14, 0)];
    
    self.tableViewQueue = [SBSMOperationQueue queue];
}

- (void)configureChattingViewWithChannel:(SBDBaseChannel *)channel {
    self.channel = channel;
    
    self.initialLoading = YES;
    self.lastMessageHeight = 0;
    self.messages = [[NSMutableArray alloc] init];
    self.scrollLock = NO;
    self.stopMeasuringVelocity = NO;
    
    self.typingIndicatorContainerView.hidden = YES;
    self.typingIndicatorContainerViewHeight.constant = 0;
    self.typingIndicatorImageHeight.constant = 0;
        
    self.messageTextView.delegate = self;
    
    self.resendableFileData = [[NSMutableDictionary alloc] init];
    self.preSendFileData = [[NSMutableDictionary alloc] init];
    
    [self.chattingTableView registerNib:[IncomingUserMessageTableViewCell nib] forCellReuseIdentifier:[IncomingUserMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingUserMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingUserMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[NeutralMessageTableViewCell nib] forCellReuseIdentifier:[NeutralMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[IncomingFileMessageTableViewCell nib] forCellReuseIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingImageFileMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingImageFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingFileMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[IncomingImageFileMessageTableViewCell nib] forCellReuseIdentifier:[IncomingImageFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[IncomingVideoFileMessageTableViewCell nib] forCellReuseIdentifier:[IncomingVideoFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingVideoFileMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingVideoFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[IncomingGeneralUrlPreviewMessageTableViewCell nib] forCellReuseIdentifier:[IncomingGeneralUrlPreviewMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingGeneralUrlPreviewMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingGeneralUrlPreviewMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingGeneralUrlPreviewTempMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingGeneralUrlPreviewTempMessageTableViewCell cellReuseIdentifier]];
    
    self.chattingTableView.delegate = self;
    self.chattingTableView.dataSource = self;
    
    [self initSizingCell];
}

- (void)initSizingCell {
    self.incomingUserMessageSizingTableViewCell = (IncomingUserMessageTableViewCell *)[[[IncomingUserMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingUserMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingUserMessageSizingTableViewCell];
    
    self.outgoingUserMessageSizingTableViewCell = (OutgoingUserMessageTableViewCell *)[[[OutgoingUserMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingUserMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingUserMessageSizingTableViewCell];
    
    self.neutralMessageSizingTableViewCell = (NeutralMessageTableViewCell *)[[[NeutralMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.neutralMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.neutralMessageSizingTableViewCell];
    
    self.incomingFileMessageSizingTableViewCell = (IncomingFileMessageTableViewCell *)[[[IncomingFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingFileMessageSizingTableViewCell];
    
    self.outgoingImageFileMessageSizingTableViewCell = (OutgoingImageFileMessageTableViewCell *)[[[OutgoingImageFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingImageFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingImageFileMessageSizingTableViewCell];
    
    self.outgoingFileMessageSizingTableViewCell = (OutgoingFileMessageTableViewCell *)[[[OutgoingFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingFileMessageSizingTableViewCell];
    
    self.incomingImageFileMessageSizingTableViewCell = (IncomingImageFileMessageTableViewCell *)[[[IncomingImageFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingImageFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingImageFileMessageSizingTableViewCell];
    
    self.incomingVideoFileMessageSizingTableViewCell = (IncomingVideoFileMessageTableViewCell *)[[[IncomingVideoFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingVideoFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingVideoFileMessageSizingTableViewCell];
    
    self.outgoingVideoFileMessageSizingTableViewCell = (OutgoingVideoFileMessageTableViewCell *)[[[OutgoingVideoFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingVideoFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingVideoFileMessageSizingTableViewCell];
    
    self.incomingGeneralUrlPreviewMessageTableViewCell = (IncomingGeneralUrlPreviewMessageTableViewCell *)[[[IncomingGeneralUrlPreviewMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingGeneralUrlPreviewMessageTableViewCell setHidden:YES];
    [self addSubview:self.incomingGeneralUrlPreviewMessageTableViewCell];
    
    self.outgoingGeneralUrlPreviewMessageTableViewCell = (OutgoingGeneralUrlPreviewMessageTableViewCell *)[[[OutgoingGeneralUrlPreviewMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingGeneralUrlPreviewMessageTableViewCell setHidden:YES];
    [self addSubview:self.outgoingGeneralUrlPreviewMessageTableViewCell];
    
    self.outgoingGeneralUrlPreviewTempMessageTableViewCell = (OutgoingGeneralUrlPreviewTempMessageTableViewCell *)[[[OutgoingGeneralUrlPreviewTempMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingGeneralUrlPreviewTempMessageTableViewCell setHidden:YES];
    [self addSubview:self.outgoingGeneralUrlPreviewTempMessageTableViewCell];
}

- (void)scrollToBottomWithForce:(BOOL)force {
    if (self.scrollLock && force == NO) {
        NSLog(@"#####[Chatting View] scroll is locked");
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger currentRowNumber = [self.chattingTableView numberOfRowsInSection:0];
        if (currentRowNumber == 0) {
            return;
        }
        
        [self.chattingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowNumber - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:NO];
    });
}

- (void)scrollToPosition:(NSInteger)position {
    if (self.messages.count == 0) {
        return;
    }

    [self.chattingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:NO];
}

- (void)startTypingIndicator:(NSString *)text {
    // Typing indicator
    self.typingIndicatorContainerView.hidden = NO;
    self.typingIndicatorLabel.text = text;
    
    self.typingIndicatorContainerViewHeight.constant = 26;
    self.typingIndicatorImageHeight.constant = 26;
    [self.typingIndicatorContainerView layoutIfNeeded];

    if (self.typingIndicatorImageView.animating == NO) {
        NSMutableArray<UIImage *> *typingImages = [[NSMutableArray alloc] init];
        for (int i = 1; i <= 50; i++) {
            NSString *typingImageFrameName = [NSString stringWithFormat:@"%02d", i];
            [typingImages addObject:[UIImage imageNamed:typingImageFrameName]];
        }
        self.typingIndicatorImageView.animationImages = typingImages;
        self.typingIndicatorImageView.animationDuration = 1.5;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.typingIndicatorImageView startAnimating];
        });
    }
}

- (void)endTypingIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.typingIndicatorImageView stopAnimating];
    });

    self.typingIndicatorContainerView.hidden = YES;
    self.typingIndicatorContainerViewHeight.constant = 0;
    self.typingIndicatorImageHeight.constant = 0;
    
    [self.typingIndicatorContainerView layoutIfNeeded];
}

#pragma mark - UI for Message
- (void)insertMessages:(NSArray<SBDBaseMessage *> *)messages comparator:(SBSMMessageComparator)comparator completionHandler:(SBSMVoidHandler)completionHandler {
    if (messages.count == 0) {
        return;
    }
    
    NSLog(@"\n+++ [MESSAGE TABLEVIEW] will insert tableView's messages - tableView: %@ - insertings: %@", self.messages, messages);
    [self.messages addObjectsFromArray:messages];
    [self.messages sortUsingComparator:comparator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chattingTableView reloadData];
        if (self.messages.lastObject.messageId == messages.lastObject.messageId) {
            [self scrollToBottomWithForce:YES];
        }
        
        if (completionHandler != nil) {
            completionHandler();
        }
    });
}

- (void)updateMessages:(NSArray<SBDBaseMessage *> *)messages completionHandler:(SBSMVoidHandler)completionHandler {
    if (messages.count == 0) {
        return;
    }
    
    NSLog(@"\n+++ [MESSAGE TABLEVIEW] will change tableView's messages - tableView: %@ - updating: %@", self.messages, messages);
    for (SBDBaseMessage *updatedMessage in messages) {
        for (SBDBaseMessage *message in self.messages) {
            if (message.messageId == updatedMessage.messageId && message != updatedMessage) {
                NSUInteger index = [self.messages indexOfObject:message];
                [self.messages replaceObjectAtIndex:index withObject:updatedMessage];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chattingTableView reloadData];
        
        if (completionHandler != nil) {
            completionHandler();
        }
    });
}

- (void)removeMessages:(NSArray<SBDBaseMessage *> *)messages completionHandler:(SBSMVoidHandler)completionHandler {
    if (messages.count == 0) {
        return;
    }
    
    NSLog(@"\n+++ [MESSAGE TABLEVIEW] will delete tableView's messages - tableView: %@ - changelogs: %@", self.messages, messages);
    NSMutableArray<NSNumber *> *removedMessageIds = [NSMutableArray array];
    NSMutableArray<NSString *> *removedRequestIds = [NSMutableArray array];
    for (SBDBaseMessage *removedMessage in messages) {
        if (removedMessage.messageId > 0) {
            [removedMessageIds addObject:@(removedMessage.messageId)];
        }
        else if ([removedMessage valueForKey:@"requestId"] != nil) {
            [removedRequestIds addObject:[removedMessage valueForKey:@"requestId"]];
        }
    }
    
    NSMutableArray<NSIndexPath *> *indexPathes = [NSMutableArray array];
    NSIndexSet *indexSet = [self.messages indexesOfObjectsPassingTest:^BOOL(SBDBaseMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (message.messageId > 0) {
            if ([removedMessageIds containsObject:@(message.messageId)]) {
                [removedMessageIds removeObject:@(message.messageId)];
                [indexPathes addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                
                if (removedMessageIds.count == 0 && removedRequestIds.count == 0) {
                    *stop = YES;
                }
                return YES;
            }
        }
        else if ([message valueForKey:@"requestId"] != nil) {
            NSString *requestId = [message valueForKey:@"requestId"];
            if ([removedRequestIds containsObject:requestId]) {
                [removedRequestIds removeObject:requestId];
                [indexPathes addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                
                if (removedMessageIds.count == 0 && removedRequestIds.count == 0) {
                    *stop = YES;
                }
                return YES;
            }
        }
        
        return NO;
    }];
    
    [Utils tableView:self.chattingTableView performBatchUpdates:^(UITableView * _Nonnull tableView) {
        [tableView deleteRowsAtIndexPaths:[indexPathes copy] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.messages removeObjectsAtIndexes:indexSet];
    } completion:^(BOOL finished) {
        if (completionHandler != nil) {
            completionHandler();
        }
    }];
}

- (void)clearAllMessagesWithCompletionHandler:(ChattingViewCompletionHandler)completionHandler {
    NSLog(@"\n+++ [MESSAGE TABLEVIEW] will clear tableView's messages - tableView: %@", self.messages);
    [Utils tableView:self.chattingTableView performBatchUpdates:^(UITableView * _Nonnull tableView) {
        [self.messages removeAllObjects];
        [tableView reloadData];
    } completion:^(BOOL finished) {
        if (completionHandler != nil) {
            completionHandler();
        }
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.messageTextView) {
        if (textView.text.length > 0) {
            self.placeholderLabel.hidden = YES;
            if (self.delegate != nil) {
                [self.delegate startTyping:self];
            }
        }
        else {
            self.placeholderLabel.hidden = NO;
            if (self.delegate != nil) {
                [self.delegate endTyping:self];
            }
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.stopMeasuringVelocity = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.stopMeasuringVelocity = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.chattingTableView) {
        if (self.stopMeasuringVelocity == NO) {
            CGPoint currentOffset = scrollView.contentOffset;
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];

            NSTimeInterval timeDiff = currentTime - self.lastOffsetCapture;
            if(timeDiff > 0.1) {
                CGFloat distance = currentOffset.y - self.lastOffset.y;
                //The multiply by 10, / 1000 isn't really necessary.......
                CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
                
                CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
                if (scrollSpeed > 0.5) {
                    self.isScrollingFast = YES;
                } else {
                    self.isScrollingFast = NO;
                }
                
                self.lastOffset = currentOffset;
                self.lastOffsetCapture = currentTime;
            }

            if (self.isScrollingFast) {
                if (self.delegate) {
                    [self.delegate hideKeyboardWhenFastScrolling:self];
                }
            }
        }
        
        if (scrollView.contentOffset.y + scrollView.frame.size.height + self.lastMessageHeight < scrollView.contentSize.height) {
            self.scrollLock = YES;
        }
        else {
            self.scrollLock = NO;
        }
        
        if (scrollView.contentOffset.y == 0) {
            if (self.messages.count > 0 && !self.initialLoading) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(loadMoreMessage:)]) {
                    [self.delegate loadMoreMessage:self];
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    SBDBaseMessage *msg = self.messages[indexPath.row];
    
    if ([msg isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)msg;
        SBDUser *sender = userMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([userMessage.customType isEqualToString:@"url_preview"]) {
                if (indexPath.row > 0) {
                    [self.outgoingGeneralUrlPreviewMessageTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingGeneralUrlPreviewMessageTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingGeneralUrlPreviewMessageTableViewCell setModel:userMessage channel:self.channel];
                height = [self.outgoingGeneralUrlPreviewMessageTableViewCell getHeightOfViewCell];
            }
            else {
                if (indexPath.row > 0) {
                    [self.outgoingUserMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingUserMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingUserMessageSizingTableViewCell setModel:userMessage channel:self.channel];
                height = [self.outgoingUserMessageSizingTableViewCell getHeightOfViewCell];
            }
        }
        else {
            // Incoming
            if ([userMessage.customType isEqualToString:@"url_preview"]) {
                if (indexPath.row > 0) {
                    [self.incomingGeneralUrlPreviewMessageTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingGeneralUrlPreviewMessageTableViewCell setPreviousMessage:nil];
                }
                [self.incomingGeneralUrlPreviewMessageTableViewCell setModel:userMessage];
                height = [self.incomingGeneralUrlPreviewMessageTableViewCell getHeightOfViewCell];
            }
            else {
                if (indexPath.row > 0) {
                    [self.incomingUserMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingUserMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingUserMessageSizingTableViewCell setModel:userMessage];
                height = [self.incomingUserMessageSizingTableViewCell getHeightOfViewCell];
            }
        }
    }
    else if ([msg isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)msg;
        SBDUser *sender = fileMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([fileMessage.type hasPrefix:@"video"]) {
                if (indexPath.row > 0) {
                    [self.outgoingVideoFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingVideoFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingVideoFileMessageSizingTableViewCell setModel:fileMessage channel:self.channel];
                height = [self.outgoingVideoFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage channel:self.channel];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                if (indexPath.row > 0) {
                    [self.outgoingImageFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingImageFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingImageFileMessageSizingTableViewCell setModel:fileMessage channel:self.channel];
                height = [self.outgoingImageFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage channel:self.channel];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
        }
        else {
            // Incoming
            if ([fileMessage.type hasPrefix:@"video"]) {
                if (indexPath.row > 0) {
                    [self.incomingVideoFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingVideoFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingVideoFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.incomingVideoFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                if (indexPath.row > 0) {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.incomingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                if (indexPath.row > 0) {
                    [self.incomingImageFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingImageFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingImageFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.incomingImageFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else {
                if (indexPath.row > 0) {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.incomingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
        }
    }
    else if ([msg isKindOfClass:[SBDAdminMessage class]]) {
        SBDAdminMessage *adminMessage = (SBDAdminMessage *)msg;
        if (indexPath.row > 0) {
            [self.neutralMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
        }
        else {
            [self.neutralMessageSizingTableViewCell setPreviousMessage:nil];
        }
        
        [self.neutralMessageSizingTableViewCell setModel:adminMessage];
        height = [self.neutralMessageSizingTableViewCell getHeightOfViewCell];
    }
    else if ([msg isKindOfClass:[OutgoingGeneralUrlPreviewTempModel class]]) {
        OutgoingGeneralUrlPreviewTempModel *tempModel = (OutgoingGeneralUrlPreviewTempModel *)msg;
        if (indexPath.row > 0) {
            [self.outgoingGeneralUrlPreviewTempMessageTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
        }
        else {
            [self.outgoingGeneralUrlPreviewTempMessageTableViewCell setPreviousMessage:nil];
        }
        [self.outgoingGeneralUrlPreviewTempMessageTableViewCell setModel:tempModel];
        height = [self.outgoingGeneralUrlPreviewTempMessageTableViewCell getHeightOfViewCell];
    }
    
    if (self.messages.count > 0 && self.messages.count - 1 == indexPath.row) {
        self.lastMessageHeight = height;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    SBDBaseMessage *msg = self.messages[indexPath.row];
    
    if ([msg isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)msg;
        SBDUser *sender = userMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([userMessage.customType isEqualToString:@"url_preview"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingGeneralUrlPreviewMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(OutgoingGeneralUrlPreviewMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingGeneralUrlPreviewMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingGeneralUrlPreviewMessageTableViewCell *)cell setModel:userMessage channel:self.channel];
                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).delegate = self.delegate;
                
                NSString *imageUrl = ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewData[@"image"];
                NSString *ext = [imageUrl pathExtension];
                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView.image = nil;
                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView.animatedImage = nil;
                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator.hidden = NO;
                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator startAnimating];
                if (imageUrl != nil && imageUrl.length > 0) {
                    if ([[ext lowercaseString] hasPrefix:@"gif"]) {
                        [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setAnimatedImageWithURL:[NSURL URLWithString:imageUrl] success:^(FLAnimatedImage * _Nullable image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setAnimatedImage:image];
                                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator.hidden = YES;
                                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator stopAnimating];
                            });
                        } failure:^(NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator.hidden = YES;
                                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator stopAnimating];
                            });
                        }];
                    }
                    else {
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
                        [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setImage:image];
                                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator.hidden = YES;
                                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator stopAnimating];
                            });
                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator.hidden = YES;
                                [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator stopAnimating];
                            });
                        }];
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator.hidden = YES;
                        [((OutgoingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageLoadingIndicator stopAnimating];
                    });
                }

                [(OutgoingGeneralUrlPreviewMessageTableViewCell *)cell showMessageDate];
                [(OutgoingGeneralUrlPreviewMessageTableViewCell *)cell showUnreadCount];
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingUserMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(OutgoingUserMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingUserMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingUserMessageTableViewCell *)cell setModel:userMessage channel:self.channel];
                ((OutgoingUserMessageTableViewCell *)cell).delegate = self.delegate;

                [(OutgoingUserMessageTableViewCell *)cell showMessageDate];
                [(OutgoingUserMessageTableViewCell *)cell showUnreadCount];
            }
        }
        else {
            // Incoming
            if ([userMessage.customType isEqualToString:@"url_preview"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingGeneralUrlPreviewMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(IncomingGeneralUrlPreviewMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingGeneralUrlPreviewMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingGeneralUrlPreviewMessageTableViewCell *)cell setModel:userMessage];
                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).delegate = self.delegate;
                
                NSString *imageUrl = ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewData[@"image"];
                NSString *ext = [imageUrl pathExtension];
                
                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView.image = nil;
                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView.animatedImage = nil;
                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator.hidden = NO;
                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator startAnimating];
                if (imageUrl != nil && imageUrl.length > 0) {
                    if ([[ext lowercaseString] hasPrefix:@"gif"]) {
                        [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setAnimatedImageWithURL:[NSURL URLWithString:imageUrl] success:^(FLAnimatedImage * _Nullable image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView.image = nil;
                                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView.animatedImage = nil;
                                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setAnimatedImage:image];
                                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator.hidden = YES;
                                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator stopAnimating];
                            });
                        } failure:^(NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator.hidden = YES;
                                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator stopAnimating];
                            });
                        }];
                    }
                    else {
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
                        [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailImageView setImage:image];
                                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator.hidden = YES;
                                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator stopAnimating];
                            });
                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator.hidden = YES;
                                [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator stopAnimating];
                            });
                        }];
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator.hidden = YES;
                        [((IncomingGeneralUrlPreviewMessageTableViewCell *)cell).previewThumbnailLoadingIndicator stopAnimating];
                    });
                }
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingUserMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(IncomingUserMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingUserMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingUserMessageTableViewCell *)cell setModel:userMessage];
                ((IncomingUserMessageTableViewCell *)cell).delegate = self.delegate;
            }
        }
    }
    else if ([msg isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)msg;
        SBDUser *sender = fileMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([fileMessage.type hasPrefix:@"video"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingVideoFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(OutgoingVideoFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingVideoFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingVideoFileMessageTableViewCell *)cell setModel:fileMessage channel:self.channel];
                ((OutgoingVideoFileMessageTableViewCell *)cell).delegate = self.delegate;
                
                [(OutgoingVideoFileMessageTableViewCell *)cell showMessageDate];
                [(OutgoingVideoFileMessageTableViewCell *)cell showUnreadCount];
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingFileMessageTableViewCell *)cell setModel:fileMessage channel:self.channel];
                ((OutgoingFileMessageTableViewCell *)cell).delegate = self.delegate;

                [(OutgoingFileMessageTableViewCell *)cell showMessageDate];
                [(OutgoingFileMessageTableViewCell *)cell showUnreadCount];
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingImageFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(OutgoingImageFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingImageFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingImageFileMessageTableViewCell *)cell setModel:fileMessage channel:self.channel];
                ((OutgoingImageFileMessageTableViewCell *)cell).delegate = self.delegate;

                if (fileMessage.url != nil && fileMessage.url.length > 0 && self.preSendFileData[fileMessage.requestId] != nil) {
                    [(OutgoingImageFileMessageTableViewCell *)cell setImageData:(NSData *)self.preSendFileData[fileMessage.requestId][@"data"] type:(NSString *)self.preSendFileData[fileMessage.requestId][@"type"]];
                    [(OutgoingImageFileMessageTableViewCell *)cell setHasImageCacheData:YES];
                    [self.preSendFileData removeObjectForKey:fileMessage.requestId];
                }
                else {
                    [(OutgoingImageFileMessageTableViewCell *)cell setHasImageCacheData:NO];
                    
                    NSString *fileImageUrl = @"";
                    if (fileMessage.thumbnails.count > 0 && ![fileMessage.type isEqualToString:@"image/gif"]) {
                        fileImageUrl = fileMessage.thumbnails[0].url;
                    }
                    else {
                        fileImageUrl = fileMessage.url;
                    }
                    
                    [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setImage:nil];
                    [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImage:nil];
                    
                    if ([fileMessage.type isEqualToString:@"image/gif"]) {
                        [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImageWithURL:[NSURL URLWithString:fileImageUrl] success:^(FLAnimatedImage * _Nullable image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                OutgoingImageFileMessageTableViewCell *updateCell = (OutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImage:image];
                                    [((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                    ((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                                }
                            });
                        } failure:^(NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                OutgoingImageFileMessageTableViewCell *updateCell = (OutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:fileImageUrl]];
                                    [((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                    ((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                                }
                            });
                        }];
                    }
                    else {
                        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:fileImageUrl]];
                        [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                OutgoingImageFileMessageTableViewCell *updateCell = (OutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((OutgoingImageFileMessageTableViewCell *)cell).fileImageView setImage:image];
                                    
                                    [((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                    ((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                                }
                            });
                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                OutgoingImageFileMessageTableViewCell *updateCell = (OutgoingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (updateCell) {
                                    [((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                    ((OutgoingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                                }
                            });
                        }];
                    }
                }
                [(OutgoingImageFileMessageTableViewCell *)cell showMessageDate];
                [(OutgoingImageFileMessageTableViewCell *)cell showUnreadCount];
                
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingFileMessageTableViewCell *)cell setModel:fileMessage channel:self.channel];
                ((OutgoingFileMessageTableViewCell *)cell).delegate = self.delegate;

                [(OutgoingFileMessageTableViewCell *)cell showMessageDate];
                [(OutgoingFileMessageTableViewCell *)cell showUnreadCount];
            }
        }
        else {
            // Incoming
            if ([fileMessage.type hasPrefix:@"video"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingVideoFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(IncomingVideoFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingVideoFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingVideoFileMessageTableViewCell *)cell setModel:fileMessage];
                ((IncomingVideoFileMessageTableViewCell *)cell).delegate = self.delegate;
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(IncomingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingFileMessageTableViewCell *)cell setModel:fileMessage];
                ((IncomingFileMessageTableViewCell *)cell).delegate = self.delegate;
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingImageFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(IncomingImageFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingImageFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingImageFileMessageTableViewCell *)cell setModel:fileMessage];
                ((IncomingImageFileMessageTableViewCell *)cell).delegate = self.delegate;
                
                NSString *fileImageUrl = @"";
                
                if (fileMessage.thumbnails.count > 0 && ![fileMessage.type isEqualToString:@"image/gif"]) {
                    fileImageUrl = fileMessage.thumbnails[0].url;
                }
                else {
                    fileImageUrl = fileMessage.url;
                }
                
                [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setImage:nil];
                [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImage:nil];
                
                ((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = NO;
                [((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator startAnimating];
                
                if ([fileMessage.type isEqualToString:@"image/gif"]) {
                    [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImageWithURL:[NSURL URLWithString:fileImageUrl] success:^(FLAnimatedImage * _Nullable image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            IncomingImageFileMessageTableViewCell *updateCell = (IncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setAnimatedImage:image];
                                
                                [((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                ((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                            }
                        });
                    } failure:^(NSError * _Nullable error) {
                        [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:fileImageUrl]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            IncomingImageFileMessageTableViewCell *updateCell = (IncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                ((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                            }
                        });
                    }];
                }
                else {
                    [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fileImageUrl]] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            IncomingImageFileMessageTableViewCell *updateCell = (IncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setImage:image];
                                
                                [((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                ((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                            }
                        });
                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                        [((IncomingImageFileMessageTableViewCell *)cell).fileImageView setImageWithURL:[NSURL URLWithString:fileImageUrl]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            IncomingImageFileMessageTableViewCell *updateCell = (IncomingImageFileMessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                [((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator stopAnimating];
                                ((IncomingImageFileMessageTableViewCell *)cell).imageLoadingIndicator.hidden = YES;
                            }
                        });
                    }];
                }
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
                if (indexPath.row > 0) {
                    [(IncomingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingFileMessageTableViewCell *)cell setModel:fileMessage];
                ((IncomingFileMessageTableViewCell *)cell).delegate = self.delegate;
            }
        }
    }
    else if ([msg isKindOfClass:[SBDAdminMessage class]]) {
        SBDAdminMessage *adminMessage = (SBDAdminMessage *)msg;
        
        cell = [tableView dequeueReusableCellWithIdentifier:[NeutralMessageTableViewCell cellReuseIdentifier]];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
        if (indexPath.row > 0) {
            [(NeutralMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
        }
        else {
            [(NeutralMessageTableViewCell *)cell setPreviousMessage:nil];
        }
        
        [(NeutralMessageTableViewCell *)cell setModel:adminMessage];
    }
    else if ([msg isKindOfClass:[OutgoingGeneralUrlPreviewTempModel class]]) {
        OutgoingGeneralUrlPreviewTempModel *model = (OutgoingGeneralUrlPreviewTempModel *)msg;
        cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingGeneralUrlPreviewTempMessageTableViewCell cellReuseIdentifier]];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.frame.size.width, cell.frame.size.height);
        if (indexPath.row > 0) {
            [(OutgoingGeneralUrlPreviewTempMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
        }
        else {
            [(OutgoingGeneralUrlPreviewTempMessageTableViewCell *)cell setPreviousMessage:nil];
        }
        [(OutgoingGeneralUrlPreviewTempMessageTableViewCell *)cell setModel:model];
    }
    
    return cell;
}

@end
