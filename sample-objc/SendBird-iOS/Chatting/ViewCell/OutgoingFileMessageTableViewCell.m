//
//  OutgoingFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "OutgoingFileMessageTableViewCell.h"
#import "Constants.h"

@interface OutgoingFileMessageTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerTopMargin;

@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fileActionImageView;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteMessageButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

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

- (void)setModel:(SBDFileMessage *)aMessage {
    self.message = aMessage;
    
    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.messageContainerView.userInteractionEnabled = YES;
    [self.messageContainerView addGestureRecognizer:messageContainerTapRecognizer];
    
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
        SBDGroupChannel *channelOfMessage = [SBDGroupChannel getChannelFromCacheWithChannelUrl:self.message.channelUrl];
        if (channelOfMessage != nil) {
            int unreadMessageCount = [channelOfMessage getReadReceiptOfMessage:self.message];
            if (unreadMessageCount == 0) {
                [self hideUnreadCount];
            }
            else {
                [self showUnreadCount];
                self.unreadCountLabel.text = [NSString stringWithFormat:@"%d", unreadMessageCount];
            }
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
            self.dateSeperatorContainerView.hidden = NO;
            self.dateContainerHeight.constant = 24.0;
            self.dateContainerTopMargin.constant = 10.0;
            self.dateContainerBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorContainerView.hidden = YES;
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
        self.dateSeperatorContainerView.hidden = NO;
        self.dateContainerHeight.constant = 24.0;
        self.dateContainerTopMargin.constant = 10.0;
        self.dateContainerBottomMargin.constant = 10.0;
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (CGFloat)getHeightOfViewCell {
    CGFloat height = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + self.messageContainerBottomPadding.constant + self.fileContainerHeight.constant;
    
    return height;
}

- (void)hideUnreadCount {
    self.unreadCountLabel.hidden = YES;
}

- (void)showUnreadCount {
    self.unreadCountLabel.hidden = NO;
}

- (void)hideMessageControlButton {
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    self.messageDateLabel.hidden = NO;
}

- (void)showMessageControlButton {
    self.resendMessageButton.hidden = NO;
    self.deleteMessageButton.hidden = NO;
    self.messageDateLabel.hidden = YES;
}

@end
