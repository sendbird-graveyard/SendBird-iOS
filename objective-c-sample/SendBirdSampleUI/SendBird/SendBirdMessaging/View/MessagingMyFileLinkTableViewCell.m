//
//  MessagingMyFileLinkTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Develpers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingMyFileLinkTableViewCell.h"

#define kMyFileLinkCellTopMargin 14.0
#define kMyFileLinkCellBottomMargin 0
#define kMyFileLinkCellLeftMargin 12
#define kMyFileLinkBalloonRightMargin 12
#define kMyFileLinkCellRightMargin 32
#define kMyFileLinkFontSize 14.0
#define kMyFileLinkBalloonTopPadding 12
#define kMyFileLinkBalloonBottomPadding 12
#define kMyFileLinkBalloonLeftPadding 12
#define kMyFileLinkBalloonRightPadding 12
#define kMyFileLinkWidth 160
#define kMyFileLinkHeight 160
#define kMyFileLinkDateTimeRightMarign 4
#define kMyFileLinkDateTimeFontSize 10.0
#define kMyFileLinkUnreadFontSize 10.0

@implementation MessagingMyFileLinkTableViewCell {
    CGFloat topMargin;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {
        topMargin = kMyFileLinkCellTopMargin;
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
    
    self.dateTimeLabel = [[UILabel alloc] init];
    [self.dateTimeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateTimeLabel setNumberOfLines:1];
    [self.dateTimeLabel setTextColor:UIColorFromRGB(0xacaab2)];
    [self.dateTimeLabel setFont:[UIFont systemFontOfSize:kMyFileLinkDateTimeFontSize]];
    [self.dateTimeLabel setText:@"11:24 PM"];
    [self addSubview:self.dateTimeLabel];
    
    self.unreadLabel = [[UILabel alloc] init];
    [self.unreadLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.unreadLabel setNumberOfLines:1];
    [self.unreadLabel setTextColor:UIColorFromRGB(0xac90ff)];
    [self.unreadLabel setFont:[UIFont systemFontOfSize:kMyFileLinkUnreadFontSize]];
    [self.unreadLabel setText:@"Unread"];
    [self addSubview:self.unreadLabel];
    
    self.fileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_icon_file"]];
    [self.fileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.fileImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:self.fileImageView];
    
    // File Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kMyFileLinkBalloonBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kMyFileLinkCellRightMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyFileLinkWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyFileLinkHeight]];
    
    // Message Background Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kMyFileLinkCellBottomMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-kMyFileLinkBalloonLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kMyFileLinkBalloonRightMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-kMyFileLinkBalloonTopPadding]];
    
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
                                                    multiplier:1 constant:-kMyFileLinkDateTimeRightMarign]];
    
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
                                                    multiplier:1 constant:-kMyFileLinkDateTimeRightMarign]];
}

- (void) setContinuousMessage:(BOOL)continuousFlag
{
    if (continuousFlag) {
        topMargin = 4.0;
    }
    else {
        topMargin = kMyFileLinkCellTopMargin;
    }
}

- (void) setModel:(SendBirdFileLink *)model
{
    self.fileLink = model;
    long long ts = [self.fileLink getMessageTimestamp] / 1000;
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
    
    if ([[[self.fileLink fileInfo] type] hasPrefix:@"image"]) {
        [SendBirdUtils loadImage:[[self.fileLink fileInfo] url] imageView:self.fileImageView width:kMyFileLinkWidth height:kMyFileLinkHeight];
    }
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    return kMyFileLinkHeight + topMargin + kMyFileLinkCellBottomMargin + kMyFileLinkBalloonTopPadding + kMyFileLinkBalloonBottomPadding;
}

@end
