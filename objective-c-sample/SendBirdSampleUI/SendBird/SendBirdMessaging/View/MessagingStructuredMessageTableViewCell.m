//
//  MessagingStructuredMessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 10. 15..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingStructuredMessageTableViewCell.h"

#define kFileLinkCellTopMargin 14

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

#define kStructuredMessageThumbnailWidth 218.0
#define kStructuredMessageThumbnailHeight 198.0
#define kStructuredBalloonTopPadding 12.0
#define kStructuredBalloonBottomPadding 5.0
#define kStructuredMessageCellBottomMargin 0
#define kStructuredMessageDividerHeight 0.5
#define kStructuredMessageDividerTopMargin 12.0
#define kStructuredMessageIconTopMargin 5.0
#define kStructuredMessageIconTopHeight 20.0
#define kStructuredMessageIconTopWidth 20.0

@implementation MessagingStructuredMessageTableViewCell

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

    self.thumbImageView = [[UIImageView alloc] init];
//    [self.thumbImageView setBackgroundColor:[UIColor redColor]];
    [self.thumbImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.thumbImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:self.thumbImageView];
    
    self.titleLabel = [[UILabel alloc] init];
//    [self.titleLabel setBackgroundColor:[UIColor blueColor]];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.titleLabel setTextColor:UIColorFromRGB(0x343434)];
    [self.titleLabel setNumberOfLines:2];
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self addSubview:self.titleLabel];
    
    self.descLabel = [[UILabel alloc] init];
//    [self.descLabel setBackgroundColor:[UIColor greenColor]];
    [self.descLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.descLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.descLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.descLabel setTextColor:UIColorFromRGB(0x8e8a99)];
    [self.descLabel setNumberOfLines:2];
    [self addSubview:self.descLabel];
    
    self.dividerView = [[UIView alloc] init];
    [self.dividerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.dividerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.dividerView];
    
    self.structuredIconImageView = [[UIImageView alloc] init];
//    [self.structuredIconImageView setBackgroundColor:[UIColor redColor]];
    [self.structuredIconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.structuredIconImageView];
    
    self.structuredNameLabel = [[UILabel alloc] init];
//    [self.structuredNameLabel setBackgroundColor:[UIColor blueColor]];
    [self.structuredNameLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.structuredNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.structuredNameLabel setTextColor:UIColorFromRGB(0x343434)];
    [self.structuredNameLabel setText:@"IMDb"];
    [self addSubview:self.structuredNameLabel];
    
    self.structuredBotImageView = [[UIImageView alloc] init];
    [self.structuredBotImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.structuredBotImageView setImage:[UIImage imageNamed:@"_icon_bot"]];
    [self addSubview:self.structuredBotImageView];

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
    
    // Thumbnail Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:19]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kStructuredMessageThumbnailWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kStructuredMessageThumbnailHeight]];
    
    // Title Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];

    // Description Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    
    // Divider
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.descLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:kStructuredMessageDividerTopMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kStructuredMessageDividerHeight]];
    
    // Icon
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-kStructuredMessageIconTopMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kStructuredMessageIconTopHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kStructuredMessageIconTopWidth]];
    
    // Structured Name
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredNameLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredNameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredNameLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredNameLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-19]];
    
    // Structured Bot Icon ImageView
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredBotImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-3.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredBotImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:19]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredBotImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:23]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredBotImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:13]];    
    
    // Profile Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kStructuredMessageCellBottomMargin]];
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
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    
    // Message Background Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:kStructuredBalloonTopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-kStructuredBalloonBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:kStructuredMessageCellBottomMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kFileLinkBalloonLeftPadding - 16]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.fileImageView
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1 constant:kFileLinkBalloonRightPadding]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.nicknameLabel
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1 constant:-kFileLinkBalloonTopPadding]];
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

- (void) setModel:(SendBirdStructuredMessage *)model
{
    self.message = model;
    SendBirdSender *sender = [self.message sender];
    long long ts = [self.message getMessageTimestamp] / 1000;
    [self.dateTimeLabel setText:[SendBirdUtils messageDateTime:ts]];
    [self.nicknameLabel setText:[sender name]];
    [self.titleLabel setText:[self.message structuredMessageTitle]];
    [self.descLabel setText:[self.message structuredMessageDesc]];
    [self.structuredNameLabel setText:[self.message structuredMessageName]];
    
    [SendBirdUtils loadImage:[sender imageUrl] imageView:self.profileImageView width:kFileLinkProfileWidth height:kFileLinkProfileHeight];

    [SendBirdUtils loadImage:[self.message structuredMessageIconUrl] imageView:self.structuredIconImageView width:kStructuredMessageIconTopWidth height:kStructuredMessageIconTopHeight];

    [SendBirdUtils loadImage:[self.message structuredMessageThumbUrl] imageView:self.thumbImageView width:kStructuredMessageThumbnailWidth height:kStructuredMessageThumbnailHeight];
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    NSString *titleText = self.titleLabel.text;
    for (int i = 0; i < [titleText length]; i++) {
        NSRange tmpRange = NSMakeRange(0, i);
        NSString *tempTitleText = [titleText substringWithRange:tmpRange];
        self.titleLabel.text = tempTitleText;
        CGSize titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(kStructuredMessageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.titleLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
        if (titleRect.height > 14 * 2) {
            break;
        }
    }
    
    NSString *descText = self.descLabel.text;
    for (int i = 0; i < [descText length]; i++) {
        NSRange tmpRange = NSMakeRange(0, i);
        NSString *tempDescText = [descText substringWithRange:tmpRange];
        self.descLabel.text = tempDescText;
        CGSize descRect = [self.descLabel.text boundingRectWithSize:CGSizeMake(kStructuredMessageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.descLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
        if (descRect.height > 10 * 2) {
            break;
        }
    }
    
    CGSize nicknameRect = [self.nicknameLabel.text boundingRectWithSize:CGSizeMake(kStructuredMessageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.nicknameLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
    CGSize titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(kStructuredMessageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.titleLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
    CGSize descRect = [self.descLabel.text boundingRectWithSize:CGSizeMake(kStructuredMessageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.descLabel.font} context:[[NSStringDrawingContext alloc] init]].size;

    return kStructuredBalloonTopPadding + nicknameRect.height + kStructuredMessageThumbnailHeight + titleRect.height + descRect.height + kStructuredMessageDividerTopMargin + kStructuredMessageDividerHeight + kStructuredMessageIconTopMargin + kStructuredMessageIconTopHeight;
}

@end
