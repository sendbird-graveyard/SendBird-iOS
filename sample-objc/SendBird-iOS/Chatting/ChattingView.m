//
//  ChattingView.m
//  SendBird-iOS
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

@interface ChattingView()
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

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (atomic) CGFloat lastMessageHeight;
@property (atomic) BOOL scrollLock;

@property (atomic) CGPoint lastOffset;
@property (atomic) NSTimeInterval lastOffsetCapture;
@property (atomic) BOOL isScrollingFast;

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
}

- (void)initChattingView {
    self.initialLoading = YES;
    self.lastMessageHeight = 0;
    self.messages = [[NSMutableArray alloc] init];
    self.scrollLock = NO;
    self.stopMeasuringVelocity = NO;
    
    self.typingIndicatorContainerView.hidden = YES;
    self.typingIndicatorContainerViewHeight.constant = 0;
    self.typingIndicatorImageHeight.constant = 0;
    
    [self.typingIndicatorContainerView layoutIfNeeded];
    
    self.messageTextView.delegate = self;
    
    self.resendableMessages = [[NSMutableDictionary alloc] init];
    
    [self.chattingTableView registerNib:[IncomingUserMessageTableViewCell nib] forCellReuseIdentifier:[IncomingUserMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingUserMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingUserMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[NeutralMessageTableViewCell nib] forCellReuseIdentifier:[NeutralMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[IncomingFileMessageTableViewCell nib] forCellReuseIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingImageFileMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingImageFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[OutgoingFileMessageTableViewCell nib] forCellReuseIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
    [self.chattingTableView registerNib:[IncomingImageFileMessageTableViewCell nib] forCellReuseIdentifier:[IncomingImageFileMessageTableViewCell cellReuseIdentifier]];
    
    self.chattingTableView.delegate = self;
    self.chattingTableView.dataSource = self;
    
    [self initSizingCell];
}

- (void)initSizingCell {
    self.incomingUserMessageSizingTableViewCell = (IncomingUserMessageTableViewCell *)[[[IncomingUserMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingUserMessageSizingTableViewCell setFrame:self.frame];
    [self.incomingUserMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingUserMessageSizingTableViewCell];
    
    self.outgoingUserMessageSizingTableViewCell = (OutgoingUserMessageTableViewCell *)[[[OutgoingUserMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingUserMessageSizingTableViewCell setFrame:self.frame];
    [self.outgoingUserMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingUserMessageSizingTableViewCell];
    
    self.neutralMessageSizingTableViewCell = (NeutralMessageTableViewCell *)[[[NeutralMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.neutralMessageSizingTableViewCell setFrame:self.frame];
    [self.neutralMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.neutralMessageSizingTableViewCell];
    
    self.incomingFileMessageSizingTableViewCell = (IncomingFileMessageTableViewCell *)[[[IncomingFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingFileMessageSizingTableViewCell setFrame:self.frame];
    [self.incomingFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingFileMessageSizingTableViewCell];
    
    self.outgoingImageFileMessageSizingTableViewCell = (OutgoingImageFileMessageTableViewCell *)[[[OutgoingImageFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingImageFileMessageSizingTableViewCell setFrame:self.frame];
    [self.outgoingImageFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingImageFileMessageSizingTableViewCell];
    
    self.outgoingFileMessageSizingTableViewCell = (OutgoingFileMessageTableViewCell *)[[[OutgoingFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.outgoingFileMessageSizingTableViewCell setFrame:self.frame];
    [self.outgoingFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.outgoingFileMessageSizingTableViewCell];
    
    self.incomingImageFileMessageSizingTableViewCell = (IncomingImageFileMessageTableViewCell *)[[[IncomingImageFileMessageTableViewCell nib] instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.incomingImageFileMessageSizingTableViewCell setFrame:self.frame];
    [self.incomingImageFileMessageSizingTableViewCell setHidden:YES];
    [self addSubview:self.incomingImageFileMessageSizingTableViewCell];
}

- (void)scrollToBottom {
    if (self.messages.count == 0) {
        return;
    }
    
    if (self.scrollLock) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chattingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}

- (void)scrollToPosition:(NSInteger)position {
    if (self.messages.count == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chattingTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
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
        
        [self scrollToBottom];
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
                    NSLog(@"Fast");
                } else {
                    self.isScrollingFast = NO;
                    NSLog(@"Slow");
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
            if (self.messages.count > 0 && self.initialLoading == NO) {
                if (self.delegate) {
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
            if (indexPath.row > 0) {
                [self.outgoingUserMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [self.outgoingUserMessageSizingTableViewCell setPreviousMessage:nil];
            }
            [self.outgoingUserMessageSizingTableViewCell setModel:userMessage];
            height = [self.outgoingUserMessageSizingTableViewCell getHeightOfViewCell];
        }
        else {
            // Incoming
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
    else if ([msg isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)msg;
        SBDUser *sender = fileMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([fileMessage.type hasPrefix:@"video"]) {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                if (indexPath.row > 0) {
                    [self.outgoingImageFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingImageFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingImageFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingImageFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
        }
        else {
            // Incoming
            if ([fileMessage.type hasPrefix:@"video"]) {
                if (indexPath.row > 0) {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.incomingFileMessageSizingTableViewCell getHeightOfViewCell];
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
    
    if (self.messages.count > 0 && self.messages.count - 1 == indexPath.row) {
        self.lastMessageHeight = height;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    SBDBaseMessage *msg = self.messages[indexPath.row];
    
    if ([msg isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *userMessage = (SBDUserMessage *)msg;
        SBDUser *sender = userMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if (indexPath.row > 0) {
                [self.outgoingUserMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [self.outgoingUserMessageSizingTableViewCell setPreviousMessage:nil];
            }
            [self.outgoingUserMessageSizingTableViewCell setModel:userMessage];
            height = [self.outgoingUserMessageSizingTableViewCell getHeightOfViewCell];
        }
        else {
            // Incoming
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
    else if ([msg isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)msg;
        SBDUser *sender = fileMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([fileMessage.type hasPrefix:@"video"]) {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                if (indexPath.row > 0) {
                    [self.outgoingImageFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingImageFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingImageFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingImageFileMessageSizingTableViewCell getHeightOfViewCell];
            }
            else {
                if (indexPath.row > 0) {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.outgoingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.outgoingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.outgoingFileMessageSizingTableViewCell getHeightOfViewCell];
            }
        }
        else {
            // Incoming
            if ([fileMessage.type hasPrefix:@"video"]) {
                if (indexPath.row > 0) {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [self.incomingFileMessageSizingTableViewCell setPreviousMessage:nil];
                }
                [self.incomingFileMessageSizingTableViewCell setModel:fileMessage];
                height = [self.incomingFileMessageSizingTableViewCell getHeightOfViewCell];
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
            cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingUserMessageTableViewCell cellReuseIdentifier]];
            if (indexPath.row > 0) {
                [(OutgoingUserMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
            }
            else {
                [(OutgoingUserMessageTableViewCell *)cell setPreviousMessage:nil];
            }
            [(OutgoingUserMessageTableViewCell *)cell setModel:userMessage];
            ((OutgoingUserMessageTableViewCell *)cell).delegate = self.delegate;

            if (self.resendableMessages[userMessage.requestId] != nil && ![self.resendableMessages[userMessage.requestId] isKindOfClass:[NSNull class]]) {
                [(OutgoingUserMessageTableViewCell *)cell showMessageControlButton];
            }
            else {
                [(OutgoingUserMessageTableViewCell *)cell hideMessageControlButton];
            }
        }
        else {
            // Incoming
            cell = [tableView dequeueReusableCellWithIdentifier:[IncomingUserMessageTableViewCell cellReuseIdentifier]];
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
    else if ([msg isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *fileMessage = (SBDFileMessage *)msg;
        SBDUser *sender = fileMessage.sender;
        
        if ([sender.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            // Outgoing
            if ([fileMessage.type hasPrefix:@"video"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
                if (indexPath.row > 0) {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingFileMessageTableViewCell *)cell setModel:fileMessage];
                ((OutgoingFileMessageTableViewCell *)cell).delegate = self.delegate;
                
                if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                    [(OutgoingFileMessageTableViewCell *)cell showMessageControlButton];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell hideMessageControlButton];
                }
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
                if (indexPath.row > 0) {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingFileMessageTableViewCell *)cell setModel:fileMessage];
                ((OutgoingFileMessageTableViewCell *)cell).delegate = self.delegate;

                if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                    [(OutgoingFileMessageTableViewCell *)cell showMessageControlButton];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell hideMessageControlButton];
                }
            }
            else if ([fileMessage.type hasPrefix:@"image"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingImageFileMessageTableViewCell cellReuseIdentifier]];
                if (indexPath.row > 0) {
                    [(OutgoingImageFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingImageFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingImageFileMessageTableViewCell *)cell setModel:fileMessage];
                ((OutgoingImageFileMessageTableViewCell *)cell).delegate = self.delegate;

                if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                    [(OutgoingImageFileMessageTableViewCell *)cell showMessageControlButton];
                }
                else {
                    [(OutgoingImageFileMessageTableViewCell *)cell hideMessageControlButton];
                }
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:[OutgoingFileMessageTableViewCell cellReuseIdentifier]];
                if (indexPath.row > 0) {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(OutgoingFileMessageTableViewCell *)cell setModel:fileMessage];
                ((OutgoingFileMessageTableViewCell *)cell).delegate = self.delegate;

                if (self.resendableMessages[fileMessage.requestId] != nil && ![self.resendableMessages[fileMessage.requestId] isKindOfClass:[NSNull class]]) {
                    [(OutgoingFileMessageTableViewCell *)cell showMessageControlButton];
                }
                else {
                    [(OutgoingFileMessageTableViewCell *)cell hideMessageControlButton];
                }
            }
        }
        else {
            // Incoming
            if ([fileMessage.type hasPrefix:@"video"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
                if (indexPath.row > 0) {
                    [(IncomingFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingFileMessageTableViewCell *)cell setModel:fileMessage];
                ((IncomingFileMessageTableViewCell *)cell).delegate = self.delegate;
            }
            else if ([fileMessage.type hasPrefix:@"audio"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
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
                if (indexPath.row > 0) {
                    [(IncomingImageFileMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
                }
                else {
                    [(IncomingImageFileMessageTableViewCell *)cell setPreviousMessage:nil];
                }
                [(IncomingImageFileMessageTableViewCell *)cell setModel:fileMessage];
                ((IncomingImageFileMessageTableViewCell *)cell).delegate = self.delegate;
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:[IncomingFileMessageTableViewCell cellReuseIdentifier]];
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
        
        if (indexPath.row > 0) {
            [(NeutralMessageTableViewCell *)cell setPreviousMessage:self.messages[indexPath.row - 1]];
        }
        else {
            [(NeutralMessageTableViewCell *)cell setPreviousMessage:nil];
        }
        
        [(NeutralMessageTableViewCell *)cell setModel:adminMessage];
    }

    return cell;
}

@end
