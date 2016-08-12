//
//  MessagingFileLinkTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingFileLinkTableViewCell.h"

#define kFileLinkCellTopMargin 14
#define kFileLinkCellBottomMargin 0
#define kFileLinkCellLeftMargin 12
#define kFileLinkFontSize 14.0
#define kFileLinkBalloonTopPadding 12
#define kFileLinkBalloonBottomPadding 12
#define kFileLinkBalloonLeftPadding 60
#define kFileLinkBalloonRightPadding 12
#define kFileLinkWidth 150
#define kFileLinkHeight 150
#define kFileLinkProfileHeight 36
#define kFileLinkProfileWidth 36
#define kFileLinkDateTimeLeftMarign 4
#define kFileLinkDateTimeFontSize 10.0
#define kFileLinkNicknameFontSize 12.0

@implementation MessagingFileLinkTableViewCell

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
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.profileImageView = [[UIImageView alloc] init];
    [self.profileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.profileImageView.layer setCornerRadius:(kFileLinkProfileHeight / 2)];
    [self.profileImageView setClipsToBounds:YES];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:self.profileImageView];
    
    self.messageBackgroundImageView = [[UIImageView alloc] init];
    [self.messageBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageBackgroundImageView setImage:[UIImage imageNamed:@"_bg_chat_bubble_gray"]];
    [self addSubview:self.messageBackgroundImageView];
    
    self.nicknameLabel = [[UILabel alloc] init];
    [self.nicknameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nicknameLabel setFont:[UIFont systemFontOfSize:kFileLinkNicknameFontSize]];
    [self.nicknameLabel setNumberOfLines:1];
    [self.nicknameLabel setTextColor:UIColorFromRGB(0xa792e5)];
    [self.nicknameLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self addSubview:self.nicknameLabel];
    
    self.dateTimeLabel = [[UILabel alloc] init];
    [self.dateTimeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateTimeLabel setNumberOfLines:1];
    [self.dateTimeLabel setTextColor:UIColorFromRGB(0xacaab2)];
    [self.dateTimeLabel setFont:[UIFont systemFontOfSize:kFileLinkDateTimeFontSize]];
    [self.dateTimeLabel setText:@"11:24 PM"];
    [self addSubview:self.dateTimeLabel];
    
    self.fileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_icon_file"]];
    [self.fileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.fileImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:self.fileImageView];
    
    // Profile Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kFileLinkCellBottomMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kFileLinkCellLeftMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kFileLinkProfileWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kFileLinkProfileHeight]];
    
    // Nickname Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kFileLinkBalloonLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kFileLinkWidth]];
    
    // File Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kFileLinkBalloonBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kFileLinkBalloonLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kFileLinkWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kFileLinkHeight]];
    
    // Message Background Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:kFileLinkCellBottomMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kFileLinkBalloonLeftPadding - 16]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:kFileLinkBalloonRightPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-kFileLinkBalloonTopPadding]];
    //    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
    //                                                     attribute:NSLayoutAttributeTop
    //                                                     relatedBy:NSLayoutRelationEqual
    //                                                        toItem:self
    //                                                     attribute:NSLayoutAttributeTop
    //                                                    multiplier:1 constant:kFileLinkCellTopMargin]];
    
    // DateTime Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateTimeLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateTimeLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:kFileLinkDateTimeLeftMarign]];
}

- (void) setModel:(SendBirdFileLink *)model
{
    self.fileLink = model;
    SendBirdSender *sender = [self.fileLink sender];
    long long ts = [self.fileLink getMessageTimestamp] / 1000;
    [self.dateTimeLabel setText:[SendBirdUtils messageDateTime:ts]];
    [self.nicknameLabel setText:[sender name]];
    
    [SendBirdUtils loadImage:[sender imageUrl] imageView:self.profileImageView width:kFileLinkProfileWidth height:kFileLinkProfileWidth];

    
    if ([[[self.fileLink fileInfo] type] hasPrefix:@"image"]) {
        [SendBirdUtils loadImage:[[model fileInfo] url] imageView:self.fileImageView width:kFileLinkWidth height:kFileLinkHeight];
    }
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    NSString *nickname = [[self.fileLink sender] name];
    CGRect nicknameRect;
    NSMutableDictionary *nicknameAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], NSFontAttributeName, nil];
    NSAttributedString *attributedNickname = [[NSAttributedString alloc] initWithString:nickname attributes:nicknameAttribute];
    
    nicknameRect = [attributedNickname boundingRectWithSize:CGSizeMake(kFileLinkWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    return nicknameRect.size.height + kFileLinkCellBottomMargin + kFileLinkBalloonBottomPadding + kFileLinkHeight + kFileLinkBalloonTopPadding + kFileLinkCellTopMargin;
}

@end
