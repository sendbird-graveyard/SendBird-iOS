//
//  MessagingMyStructuredMessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 10. 15..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingMyStructuredMessageTableViewCell.h"
#import "SendBirdCommon.h"

#define kMyMessageCellTopMargin 14
#define kMyMessageCellBottomMargin 0
#define kMyMessageCellLeftMargin 12
#define kMyMessageBalloonRightMargin 12
#define kMyMessageCellRightMargin 32
#define kMyMessageFontSize 14.0
#define kMyMessageBalloonTopPadding 12
#define kMyMessageBalloonBottomPadding 5
#define kMyMessageBalloonLeftPadding 12
#define kMyMessageBalloonRightPadding 19
#define kMyMessageMaxWidth 168
#define kMyMessageDateTimeRightMarign 4
#define kMyMessageDateTimeFontSize 10.0
#define kMyMessageUnreadFontSize 10.0

#define kMyMessageImageThumbnailWidth 218.0
#define kMyMessageImageThumbnailHeight 218.0

#define kMyMessageDividerTopMargin 12.0
#define kMyMessageDividerHeight 0.5
#define kMyMessageDividerBottomMargin 10.0

#define kMyMessageIconWidth 20
#define kMyMessageIconHeight 20

@implementation MessagingMyStructuredMessageTableViewCell{
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
    
    
    // Image Thumbnail
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:kMyMessageBalloonTopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kMyMessageBalloonLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kMyMessageBalloonRightPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyMessageImageThumbnailWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyMessageImageThumbnailHeight]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    
    // Title Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.descLabel
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kMyMessageBalloonLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kMyMessageBalloonRightPadding]];

    // Desc Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.dividerView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-19]];
    
    // Divider
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:0.5]];

    // Icon
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:-5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyMessageIconHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:kMyMessageIconWidth]];
    
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
    
    // Message Background Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.structuredIconImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:kMyMessageBalloonBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageBackgroundImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    
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

- (void) setModel:(SendBirdStructuredMessage *)message
{
    self.message = message;
//    [self.messageLabel setAttributedText:[self buildMessage]];
    [self.titleLabel setText:[message structuredMessageTitle]];
    [self.descLabel setText:[message structuredMessageDesc]];
    [self.structuredNameLabel setText:[message structuredMessageName]];
    
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
    
#define __WITH_AFNETWORKING__
#ifdef __WITH_AFNETWORKING__
    [self.structuredIconImageView setImageWithURL:[NSURL URLWithString:[message structuredMessageIconUrl]]];
#else
#warning THIS IS SAMPLE CODE. Do not use ImageCache in your product. Use your own image loader or 3rd party image loader.
    UIImage *iconImage = [[ImageCache sharedInstance] getImage:[message structuredMessageIconUrl]];
    if (iconImage) {
        @try {
            [self.structuredIconImageView setImage:iconImage];
        }
        @catch (NSException *exception) {
            NSLog(@"FileLink Exception");
        }
        @finally {
        }
    }
    else {
        [SendBirdUtils imageDownload:[NSURL URLWithString:[message structuredMessageIconUrl]] endBlock:^(NSData *response, NSError *error) {
            UIImage *image = [[UIImage alloc] initWithData:response scale:1];
//            UIImage *newImage = [SendBirdUtils imageWithImage:image scaledToSize:198];
            UIImage *newImage = image;
            
            [[ImageCache sharedInstance] setImage:newImage withKey:[message structuredMessageIconUrl]];
            @try {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^(void) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.structuredIconImageView setImage:newImage];
                    });
                });
            }
            @catch (NSException *exception) {
                NSLog(@"FileLink Exception");
            }
            @finally {
            }
        }];
    }
    [self setNeedsLayout];
#endif
    
#ifdef __WITH_AFNETWORKING__
    [self.thumbImageView setImageWithURL:[NSURL URLWithString:[message structuredMessageThumbUrl]]];
#else
#warning THIS IS SAMPLE CODE. Do not use ImageCache in your product. Use your own image loader or 3rd party image loader.
    UIImage *image = [[ImageCache sharedInstance] getImage:[message structuredMessageThumbUrl]];
    if (image) {
        @try {
            [self.thumbImageView setImage:image];
        }
        @catch (NSException *exception) {
            NSLog(@"FileLink Exception");
        }
        @finally {
        }
    }
    else {
        [SendBirdUtils imageDownload:[NSURL URLWithString:[message structuredMessageThumbUrl]] endBlock:^(NSData *response, NSError *error) {
            UIImage *image = [[UIImage alloc] initWithData:response scale:1];
            //            UIImage *newImage = [SendBirdUtils imageWithImage:image scaledToSize:198];
            UIImage *newImage = image;
            
            [[ImageCache sharedInstance] setImage:newImage withKey:[message structuredMessageThumbUrl]];
            @try {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^(void) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.thumbImageView setImage:newImage];
                    });
                });
            }
            @catch (NSException *exception) {
                NSLog(@"FileLink Exception");
            }
            @finally {
            }
        }];
    }
    [self setNeedsLayout];
#endif
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
    NSString *titleText = self.titleLabel.text;
    for (int i = 0; i < [titleText length]; i++) {
        NSRange tmpRange = NSMakeRange(0, i);
        NSString *tempTitleText = [titleText substringWithRange:tmpRange];
        self.titleLabel.text = tempTitleText;
        CGSize titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(kMyMessageImageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.titleLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
        if (titleRect.height > 14 * 2) {
            break;
        }
    }
    
    NSString *descText = self.descLabel.text;
    for (int i = 0; i < [descText length]; i++) {
        NSRange tmpRange = NSMakeRange(0, i);
        NSString *tempDescText = [descText substringWithRange:tmpRange];
        self.descLabel.text = tempDescText;
        CGSize descRect = [self.descLabel.text boundingRectWithSize:CGSizeMake(kMyMessageImageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.descLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
        if (descRect.height > 10 * 2) {
            break;
        }
    }
    
    CGSize titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(kMyMessageImageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.titleLabel.font} context:[[NSStringDrawingContext alloc] init]].size;
    CGSize descRect = [self.descLabel.text boundingRectWithSize:CGSizeMake(kMyMessageImageThumbnailWidth, CGFLOAT_MAX)  options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.descLabel.font} context:[[NSStringDrawingContext alloc] init]].size;

    return kMyMessageCellTopMargin + kMyMessageBalloonTopPadding + kMyMessageImageThumbnailHeight + titleRect.height + descRect.height + kMyMessageDividerTopMargin + kMyMessageDividerHeight + kMyMessageDividerBottomMargin + kMyMessageIconHeight + kMyMessageBalloonBottomPadding;
}

@end
