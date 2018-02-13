//
//  OutgoingGeneralUrlPreviewMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jebeom Gyeong on 16/03/2017.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "OutgoingGeneralUrlPreviewMessageTableViewCell.h"
#import "Utils.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface OutgoingGeneralUrlPreviewMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewSiteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteMessageButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UILabel *sendStatusLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dividerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dividerViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewSiteNameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewSiteNameLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTitleLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTitleLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewDescriptionLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbnailImageViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbnailImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewSiteNameLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTitleLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewDescriptionLabelWidth;

@property (strong, nonatomic) SBDUserMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation OutgoingGeneralUrlPreviewMessageTableViewCell

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

- (void)clickPreview {
    NSString *url = self.previewData[@"url"];
    if (url != nil && url.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)setModel:(SBDUserMessage *)aMessage {
    self.message = aMessage;

    NSData *data = [self.message.data dataUsingEncoding:NSUTF8StringEncoding];
    @autoreleasepool {
        self.previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }

    NSString *siteName = self.previewData[@"site_name"];
    NSString *title = self.previewData[@"title"];
    NSString *description = self.previewData[@"description"];
    
    UITapGestureRecognizer *previewThumbnailImageViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPreview)];
    self.previewThumbnailImageView.userInteractionEnabled = YES;
    [self.previewThumbnailImageView addGestureRecognizer:previewThumbnailImageViewTapRecognizer];
    
    UITapGestureRecognizer *previewSiteNameLabelTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPreview)];
    self.previewSiteNameLabel.userInteractionEnabled = YES;
    [self.previewSiteNameLabel addGestureRecognizer:previewSiteNameLabelTapRecognizer];
    
    UITapGestureRecognizer *previewTitleLabelTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPreview)];
    self.previewTitleLabel.userInteractionEnabled = YES;
    [self.previewTitleLabel addGestureRecognizer:previewTitleLabelTapRecognizer];
    
    UITapGestureRecognizer *previewDescriptionLabelTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPreview)];
    self.previewDescriptionLabel.userInteractionEnabled = YES;
    [self.previewDescriptionLabel addGestureRecognizer:previewDescriptionLabelTapRecognizer];
    
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
    [self.resendMessageButton addTarget:self action:@selector(clickResendUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteMessageButton addTarget:self action:@selector(clickDeleteUserMessage) forControlEvents:UIControlEventTouchUpInside];
    
    // Unread message count
    if ([self.message.channelType isEqualToString:CHANNEL_TYPE_GROUP]) {
        SBDGroupChannel *channelOfMessage = [SBDGroupChannel getChannelFromCacheWithChannelUrl:self.message.channelUrl];
        if (channelOfMessage != nil) {
            int unreadMessageCount = [channelOfMessage getReadReceiptOfMessage:self.message];
            if (unreadMessageCount == 0) {
                [self hideUnreadCount];
                self.unreadCountLabel.text = @"";
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
    self.dateSeperatorView.hidden = NO;
    self.dateSeperatorViewHeight.constant = 24.0;
    self.dateSeperatorViewTopMargin.constant = 10.0;
    self.dateSeperatorViewBottomMargin.constant = 10.0;
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
    
    self.previewSiteNameLabel.text = siteName;
    self.previewTitleLabel.text = title;
    self.previewDescriptionLabel.text = description;
    
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
    NSAttributedString *message = [self buildMessage];
    NSDictionary *descriptionAttributes = @{NSFontAttributeName: [Constants urlPreviewDescriptionFont]};
    NSString *description = self.previewData[@"description"];
    CGRect descriptionRect = [description boundingRectWithSize:CGSizeMake(self.previewDescriptionLabelWidth.constant, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:descriptionAttributes context:nil];
    CGFloat descriptionLabelHeight = descriptionRect.size.height;
    CGRect messageRect = [message boundingRectWithSize:CGSizeMake(self.messageLabelWidth.constant, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat messageHeight = messageRect.size.height;
    
    CGFloat cellHeight = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageLabelTopMargin.constant + messageHeight + self.messageLabelBottomMargin.constant + self.dividerViewHeight.constant + self.dividerViewBottomMargin.constant + self.previewSiteNameLabelHeight.constant + self.previewSiteNameLabelBottomMargin.constant + self.previewTitleLabelHeight.constant + self.previewTitleLabelBottomMargin.constant + descriptionLabelHeight + self.previewDescriptionLabelBottomMargin.constant + self.previewThumbnailImageViewHeight.constant;

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
    self.sendStatusLabel.hidden = YES;
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
    
    self.sendStatusLabel.hidden = NO;
    self.sendStatusLabel.text = @"Sending";
}

- (void)showFailedStatus {
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
    self.sendStatusLabel.hidden = NO;
    self.sendStatusLabel.text = @"Failed";
}

- (void)showMessageDate {
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.sendStatusLabel.hidden = YES;
    
    self.messageDateLabel.hidden = NO;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
