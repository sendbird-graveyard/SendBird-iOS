//
//  BroadcastMessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "BroadcastMessageTableViewCell.h"

#define kBroadcastMessageCellTopMargin 6
#define kBroadcastMessageCellBottomMargin 6
#define kBroadcastMessageCellLeftMargin 15
#define kBroadcastMessageCellRightMargin 15
#define kBroadcastMessageCellTopPadding 8
#define kBroadcastMessageCellBottomPadding 8
#define kBroadcastMessageCellLeftPadding 8
#define kBroadcastMessageCellRightPadding 8
#define kBroadcastMessageFontSize 14.0

@implementation BroadcastMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {
        [self initViews];
    }
    
    return self;
}

- (void) initViews
{
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.innerView = [[UIView alloc] init];
    [self.innerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.innerView setBackgroundColor:UIColorFromRGB(0xe3e3e3)];
    
    self.messageLabel = [[UILabel alloc] init];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setFont:[UIFont systemFontOfSize:kBroadcastMessageFontSize]];
    [self.messageLabel setNumberOfLines:0];
    [self.messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
    
    [self.contentView addSubview:self.innerView];
    [self.contentView addSubview:self.messageLabel];
    
    // Content View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    
    // Inner View
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.innerView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kBroadcastMessageCellTopMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.innerView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:kBroadcastMessageCellLeftMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.innerView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kBroadcastMessageCellRightMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.innerView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:-kBroadcastMessageCellBottomMargin]];
    
    // Message Label
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.innerView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kBroadcastMessageCellTopPadding]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.innerView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:kBroadcastMessageCellLeftPadding]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.innerView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:-kBroadcastMessageCellRightPadding]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.innerView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:-kBroadcastMessageCellBottomPadding]];
}

- (void) setModel:(SendBirdBroadcastMessage *)message
{
    self.message = message;
    [self.messageLabel setAttributedText:[self buildMessage]];
}

- (NSAttributedString *)buildMessage
{
    NSMutableDictionary *messageAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:kBroadcastMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x747284), NSForegroundColorAttributeName, nil];
    
    NSString *message = [[self.message message] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"\u2011"];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange messageRange = NSMakeRange(0, [[self.message message] length]);
    
    [attributedMessage beginEditing];
    [attributedMessage setAttributes:messageAttribute range:messageRange];
    [attributedMessage endEditing];
    
    return attributedMessage;
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    CGFloat messageWidth;
    CGRect messageRect;
    NSAttributedString *attributedMessage = [self buildMessage];
    
    messageWidth = totalWidth - (kBroadcastMessageCellLeftMargin + kBroadcastMessageCellRightMargin + kBroadcastMessageCellLeftPadding + kBroadcastMessageCellRightPadding);
    messageRect = [attributedMessage boundingRectWithSize:CGSizeMake(messageWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    return messageRect.size.height + kBroadcastMessageCellTopMargin + kBroadcastMessageCellBottomMargin + kBroadcastMessageCellTopPadding + kBroadcastMessageCellBottomPadding;
}

@end
