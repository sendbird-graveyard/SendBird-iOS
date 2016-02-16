//
//  MessagingMyMessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingMyMessageTableViewCell.h"

#define kMyMessageCellTopMargin 14
#define kMyMessageCellBottomMargin 0
#define kMyMessageCellLeftMargin 12
#define kMyMessageBalloonRightMargin 12
#define kMyMessageCellRightMargin 32
#define kMyMessageFontSize 14.0
#define kMyMessageBalloonTopPadding 12
#define kMyMessageBalloonBottomPadding 12
#define kMyMessageBalloonLeftPadding 12
#define kMyMessageBalloonRightPadding 12
#define kMyMessageMaxWidth 168
#define kMyMessageDateTimeRightMarign 4
#define kMyMessageDateTimeFontSize 10.0
#define kMyMessageUnreadFontSize 10.0

@implementation MessagingMyMessageTableViewCell {
    CGFloat topMargin;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {
        topMargin = kMyMessageCellTopMargin;
        [self initViews];
    }
    
    return self;
}

- (void) initViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.messageBackgroundImageView = [[UIImageView alloc] init];
    [self.messageBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageBackgroundImageView setImage:[UIImage imageNamed:@"_bg_chat_bubble_purple"]];
    [self addSubview:self.messageBackgroundImageView];
    
    self.messageLabel = [[UILabel alloc] init];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setFont:[UIFont systemFontOfSize:14]];
    [self.messageLabel setNumberOfLines:0];
    [self.messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self addSubview:self.messageLabel];
    
    self.dateTimeLabel = [[UILabel alloc] init];
    [self.dateTimeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateTimeLabel setNumberOfLines:1];
    [self.dateTimeLabel setTextColor:UIColorFromRGB(0xacaab2)];
    [self.dateTimeLabel setFont:[UIFont systemFontOfSize:kMyMessageDateTimeFontSize]];
    [self.dateTimeLabel setText:@"11:24 PM"];
    [self addSubview:self.dateTimeLabel];
    
    self.unreadLabel = [[UILabel alloc] init];
    [self.unreadLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.unreadLabel setNumberOfLines:1];
    [self.unreadLabel setTextColor:UIColorFromRGB(0xac90ff)];
    [self.unreadLabel setFont:[UIFont systemFontOfSize:kMyMessageUnreadFontSize]];
    [self.unreadLabel setText:@"Unread"];
    [self.unreadLabel setHidden:YES];
    [self addSubview:self.unreadLabel];
    
    // Message Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kMyMessageBalloonBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kMyMessageCellRightMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyMessageMaxWidth]];
    
    // Message Background Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kMyMessageCellBottomMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageLabel
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-kMyMessageBalloonLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kMyMessageBalloonRightMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-kMyMessageBalloonTopPadding]];
    
    // DateTime Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateTimeLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateTimeLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-kMyMessageDateTimeRightMarign]];
    
    // Unread Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.dateTimeLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-kMyMessageDateTimeRightMarign]];
}

- (void) setContinuousMessage:(BOOL)continuousFlag
{
    if (continuousFlag) {
        topMargin = 4.0;
    }
    else {
        topMargin = kMyMessageCellTopMargin;
    }
}

- (void) setModel:(SendBirdMessage *)message
{
    self.message = message;
    [self.messageLabel setAttributedText:[self buildMessage]];
    long long ts = [self.message getMessageTimestamp] / 1000;
    [self.dateTimeLabel setText:[SendBirdUtils messageDateTime:ts]];
    [self.unreadLabel setHidden:YES];
    
    int unreadCount = 0;
    if (self.readStatus != nil) {
        for (NSString *key in self.readStatus) {
            if (![key isEqualToString:[SendBird getUserId]]) {
                long long readTime = [[self.readStatus objectForKey:key] longLongValue] / 1000;
                if (ts <= readTime) {
                    //                    [self.unreadLabel setHidden:YES];
                }
                else {
                    unreadCount = unreadCount + 1;
                }
            }
        }
    }
    
    if (unreadCount == 0) {
        [self.unreadLabel setHidden:YES];
    }
    else {
        [self.unreadLabel setHidden:NO];
        [self.unreadLabel setText:[NSString stringWithFormat:@"Unread %d", unreadCount]];
    }
}

- (NSAttributedString *)buildMessage
{
    NSMutableDictionary *messageAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kMyMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x3d3d3d), NSForegroundColorAttributeName,nil];
    NSMutableDictionary *urlAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kMyMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x2981e1), NSForegroundColorAttributeName,nil];
    
    NSString *message = [[NSString stringWithFormat:@"%@", [self.message message]] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    NSString *url = [SendBirdUtils getUrlFromString:[self.message message]];
    NSRange urlRange;
    if ([url length] > 0) {
        urlRange = [message rangeOfString:url];
    }
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"\u2011"];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange messageRange = NSMakeRange(0, [[self.message message] length]);
    
    [attributedMessage beginEditing];
    [attributedMessage setAttributes:messageAttribute range:messageRange];
    if ([url length] > 0) {
        [attributedMessage setAttributes:urlAttribute range:urlRange];
    }
    [attributedMessage endEditing];
    
    return attributedMessage;
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    CGRect messageRect;
    NSAttributedString *attributedMessage = [self buildMessage];
    
    messageRect = [attributedMessage boundingRectWithSize:CGSizeMake(kMyMessageMaxWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    return messageRect.size.height + topMargin + kMyMessageCellBottomMargin + kMyMessageBalloonTopPadding + kMyMessageBalloonBottomPadding;
}

@end
