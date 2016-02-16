//
//  MessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessageTableViewCell.h"

#define kMessageCellTopMargin 4
#define kMessageCellBottomMargin 4
#define kMessageCellLeftMargin 15
#define kMessageCellRightMargin 15
#define kMessageFontSize 14.0

@implementation MessageTableViewCell

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
    
    self.messageLabel = [[UILabel alloc] init];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setFont:[UIFont systemFontOfSize:kMessageFontSize]];
    [self.messageLabel setNumberOfLines:0];
    [self.messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
    
    [self.contentView addSubview:self.messageLabel];
    
    // Message Label
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kMessageCellTopMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:kMessageCellLeftMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:-kMessageCellRightMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:kMessageCellBottomMargin]];
    
    // Content View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
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
}

- (void) setModel:(SendBirdMessage *)message
{
    self.message = message;
    [self.messageLabel setAttributedText:[self buildMessage]];
}

- (NSAttributedString *)buildMessage
{
    NSMutableDictionary *nameAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:kMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x824096), NSForegroundColorAttributeName, nil];
    NSMutableDictionary *messageAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x595959), NSForegroundColorAttributeName,nil];
    NSMutableDictionary *urlAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x01579b), NSForegroundColorAttributeName,nil];
    
    NSString *message = [[NSString stringWithFormat:@"%@: %@", [[self.message sender] name], [self.message message]] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    NSString *url = [SendBirdUtils getUrlFromString:[self.message message]];
    NSRange urlRange;
    if ([url length] > 0) {
        urlRange = [message rangeOfString:url];
    }
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"\u2011"];
    
    int badge = 0;
    if ([self.message isOpMessage]) {
        message = [NSString stringWithFormat:@"\u00A0\u00A0%@", message];
        badge = 2;
    }
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange nameRange = NSMakeRange(badge, [[[self.message sender] name] length]);
    NSRange messageRange = NSMakeRange([[[self.message sender] name] length] + badge, [[self.message message] length] + 2);
    
    if ([self.message isOpMessage]) {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"_icon_admin"];
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedMessage replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
    }
    
    [attributedMessage beginEditing];
    [attributedMessage setAttributes:nameAttribute range:nameRange];
    [attributedMessage setAttributes:messageAttribute range:messageRange];
    if ([url length] > 0) {
        [attributedMessage setAttributes:urlAttribute range:urlRange];
    }
    [attributedMessage endEditing];
    
    return attributedMessage;
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    CGFloat messageWidth;
    CGRect messageRect;
    NSAttributedString *attributedMessage = [self buildMessage];
    
    messageWidth = totalWidth - (kMessageCellLeftMargin + kMessageCellRightMargin);
    messageRect = [attributedMessage boundingRectWithSize:CGSizeMake(messageWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    return messageRect.size.height + kMessageCellTopMargin + kMessageCellBottomMargin;
}

@end
