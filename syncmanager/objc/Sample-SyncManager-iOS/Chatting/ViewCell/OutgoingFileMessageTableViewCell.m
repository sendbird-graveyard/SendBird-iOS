//
//  OutgoingFileMessageTableViewCell.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "OutgoingFileMessageTableViewCell.h"
#import "Constants.h"

@interface OutgoingFileMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fileActionImageView;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendingStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteMessageButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileContainerViewHeight;

@property (strong, nonatomic) SBDFileMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation OutgoingFileMessageTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)clickFileMessage {
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

- (void)setModel:(SBDFileMessage *)aMessage channel:(SBDBaseChannel *)channel {
    self.message = aMessage;
    
    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.messageContainerView.userInteractionEnabled = YES;
    [self.messageContainerView addGestureRecognizer:messageContainerTapRecognizer];
    
    [self.resendMessageButton addTarget:self action:@selector(clickResendUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteMessageButton addTarget:self action:@selector(clickDeleteUserMessage) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.message.type hasPrefix:@"video"]) {
        [self.fileTypeImageView setImage:[UIImage imageNamed:@"icon_video_chat"]];
        [self.fileActionImageView setImage:[UIImage imageNamed:@"btn_play_chat"]];
    }
    else if ([self.message.type hasPrefix:@"audio"]) {
        [self.fileTypeImageView setImage:[UIImage imageNamed:@"icon_voice_chat"]];
        [self.fileActionImageView setImage:[UIImage imageNamed:@"btn_play_chat"]];
    }
    else {
        [self.fileTypeImageView setImage:[UIImage imageNamed:@"icon_file_chat"]];
        [self.fileActionImageView setImage:[UIImage imageNamed:@"btn_download_chat"]];
    }
    
    self.filenameLabel.text = [self.message name];
    
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
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorView.hidden = NO;
            self.dateSeperatorViewHeight.constant = 24.0;
            self.dateSeperatorViewTopMargin.constant = 10.0;
            self.dateSeperatorViewBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorView.hidden = YES;
            self.dateSeperatorViewHeight.constant = 0;
            self.dateSeperatorViewBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateSeperatorViewTopMargin.constant = 10.0;
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
                        self.dateSeperatorViewTopMargin.constant = 5.0;
                    }
                    else {
                        // Set default margin.
                        self.dateSeperatorViewTopMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateSeperatorViewTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorView.hidden = NO;
        self.dateSeperatorViewHeight.constant = 24.0;
        self.dateSeperatorViewTopMargin.constant = 10.0;
        self.dateSeperatorViewBottomMargin.constant = 10.0;
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (CGFloat)getHeightOfViewCell {
    CGFloat height = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageContainerViewTopPadding.constant + self.messageContainerViewBottomPadding.constant + self.fileContainerViewHeight.constant;
    
    return height;
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

@end
