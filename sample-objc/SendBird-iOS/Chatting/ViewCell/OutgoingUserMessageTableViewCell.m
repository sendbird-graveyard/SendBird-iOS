//
//  OutgoingUserMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/22/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "OutgoingUserMessageTableViewCell.h"
#import "Constants.h"

@interface OutgoingUserMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteMessageButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendingStatusLabel;

// For Cell Height
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomPadding;

// For Message Label Width
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelWidth;

@property (strong, nonatomic) SBDUserMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation OutgoingUserMessageTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)clickUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)clickResendUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickResend:self message:self.message];
    }
}

- (void)clickDeleteUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickDelete:self message:self.message];
    }
}

- (void)setModel:(SBDUserMessage *)aMessage channel:(SBDBaseChannel *)channel {
    self.message = aMessage;
    
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
//    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserMessage)];
//    self.messageContainerView.userInteractionEnabled = YES;
//    [self.messageContainerView addGestureRecognizer:messageContainerTapRecognizer];
    
    [self.resendMessageButton addTarget:self action:@selector(clickResendUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteMessageButton addTarget:self action:@selector(clickDeleteUserMessage) forControlEvents:UIControlEventTouchUpInside];
    
    // Unread message count
    if ([self.message.channelType isEqualToString:CHANNEL_TYPE_GROUP]) {
        int unreadMessageCount = [(SBDGroupChannel *)channel getReadReceiptOfMessage:self.message];
        if (unreadMessageCount == 0) {
            [self hideUnreadCount];
            self.unreadCountLabel.text = @"";
        }
        else {
            [self showUnreadCount];
            self.unreadCountLabel.text = [NSString stringWithFormat:@"%d", unreadMessageCount];
        }
    }
    else {
        [self hideUnreadCount];
    }
    
    // Message Date
    NSDictionary *messageDateAttribute = @{
                                           NSFontAttributeName: [Constants messageDateFont],
                                           NSForegroundColorAttributeName: [Constants messageDateColor]
                                           };
    NSTimeInterval messageTimestamp = (double)self.message.createdAt / 1000.0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageTimestamp];
    NSString *messageDateString = [dateFormatter stringFromDate:messageCreatedDate];
    
    NSMutableAttributedString *messageDateAttributedString = [[NSMutableAttributedString alloc] initWithString:messageDateString attributes:messageDateAttribute];
    self.messageDateLabel.attributedText = messageDateAttributedString;

    // Seperator Date
    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateSeperatorLabel.text = [seperatorDateFormatter stringFromDate:messageCreatedDate];
    
    // Relationship between the current message and the previous message
    self.dateSeperatorView.hidden = NO;
    self.dateContainerHeight.constant = 24.0;
    self.dateContainerTopMargin.constant = 10.0;
    self.dateContainerBottomMargin.constant = 10.0;
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorView.hidden = NO;
            self.dateContainerHeight.constant = 24.0;
            self.dateContainerTopMargin.constant = 10.0;
            self.dateContainerBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorView.hidden = YES;
            self.dateContainerHeight.constant = 0;
            self.dateContainerBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateContainerTopMargin.constant = 10.0;
            }
            else {
                SBDUser *prevMessageSender = nil;
                SBDUser *currMessageSender = nil;
                
                if ([self.prevMessage isKindOfClass:[SBDUserMessage class]]) {
                    prevMessageSender = [(SBDUserMessage *)self.prevMessage sender];
                }
                else if ([self.prevMessage isKindOfClass:[SBDFileMessage class]]) {
                    prevMessageSender = [(SBDFileMessage *)self.prevMessage sender];
                }
                
                currMessageSender = [self.message sender];
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.dateContainerTopMargin.constant = 5.0;
                    }
                    else {
                        // Set default margin.
                        self.dateContainerTopMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateContainerTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorView.hidden = NO;
        self.dateContainerHeight.constant = 24.0;
        self.dateContainerTopMargin.constant = 10.0;
        self.dateContainerBottomMargin.constant = 10.0;
    }
    
    NSAttributedString *fullMessage = [self buildMessage];
    self.messageLabel.attributedText = fullMessage;
    self.messageLabel.userInteractionEnabled = YES;
    self.messageLabel.linkAttributes = @{
                                         NSFontAttributeName: [Constants messageFont],
                                         NSForegroundColorAttributeName: [Constants outgoingMessageColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                         };
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error == nil) {
        NSArray *matches = [detector matchesInString:self.message.message options:0 range:NSMakeRange(0, self.message.message.length)];
        if (matches.count > 0) {
            self.messageLabel.delegate = self;
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            for (NSTextCheckingResult *match in matches) {
                NSRange range = [match range];
                [self.messageLabel addLinkToURL:[match URL] withRange:range];
            }
        }
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (NSAttributedString *)buildMessage {
    NSDictionary *messageAttribute = @{
                                       NSFontAttributeName: [Constants messageFont],
                                       NSForegroundColorAttributeName: [Constants outgoingMessageColor],
                                       };
    
    NSString *message = self.message.message;
    
    NSMutableAttributedString *fullMessage = [[NSMutableAttributedString alloc] initWithString:message];
    
    [fullMessage addAttributes:messageAttribute range:NSMakeRange(0, [message length])];
    
    return fullMessage;
}

- (CGFloat)getHeightOfViewCell {
    NSAttributedString *fullMessage = [self buildMessage];
    CGSize fullMessageSize;
    
    CGFloat messageLabelMaxWidth = [UIScreen mainScreen].bounds.size.width - (self.messageContainerRightMargin.constant + self.messageContainerRightPadding.constant + self.messageContainerLeftPadding.constant + self.messageContainerLeftMargin.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)fullMessage);
    
    fullMessageSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSizeMake(messageLabelMaxWidth, CGFLOAT_MAX), nil);
    CGFloat cellHeight = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageSize.height + self.messageContainerBottomPadding.constant;
    
    CFRelease(framesetter);
    
    return cellHeight;
}

- (void)hideUnreadCount {
    self.unreadCountLabel.hidden = YES;
}

- (void)showUnreadCount {
    if ([self.message.channelType isEqualToString:CHANNEL_TYPE_GROUP]) {
        self.unreadCountLabel.hidden = NO;
        self.resendMessageButton.hidden = YES;
        self.deleteMessageButton.hidden = YES;
    }
}

- (void)hideMessageControlButton {
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
}

- (void)showMessageControlButton {
    self.sendingStatusLabel.hidden = YES;
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    
    self.resendMessageButton.hidden = NO;
    self.deleteMessageButton.hidden = NO;
}

- (void)showSendingStatus {
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
    self.sendingStatusLabel.hidden = NO;
    self.sendingStatusLabel.text = @"Sending";
}

- (void)showFailedStatus {
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
    self.sendingStatusLabel.hidden = NO;
    self.sendingStatusLabel.text = @"Failed";
}

- (void)showMessageDate {
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.sendingStatusLabel.hidden = YES;
    
    self.messageDateLabel.hidden = NO;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
