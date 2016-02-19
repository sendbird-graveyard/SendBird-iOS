//
//  MessagingChannelTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessagingChannelTableViewCell.h"

#define kChannelUrlFontSize 14.0
#define kChannelMembersFontSize 11.0
#define kChannelCoverRadius 19.0
#define kChannelLastMessageFontSize 11.0
#define kChannelLastMessageDateFontSize 9.0
#define kChannelUnreadCountFontSize 11.0

@implementation MessagingChannelTableViewCell {
    NSLayoutConstraint *memberCountImageViewWidthConstraint;
}

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
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.profileImageView = [[UIImageView alloc] init];
    [self.profileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.profileImageView.layer setCornerRadius:kChannelCoverRadius];
    [self.profileImageView setClipsToBounds:YES];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:self.profileImageView];
    
    self.nicknameLabel = [[UILabel alloc] init];
    [self.nicknameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nicknameLabel setFont:[UIFont boldSystemFontOfSize:kChannelUrlFontSize]];
    [self.nicknameLabel setTextColor:UIColorFromRGB(0x3d3d3d)];
    [self addSubview:self.nicknameLabel];
    
    self.lastMessageLabel = [[UILabel alloc] init];
    [self.lastMessageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.lastMessageLabel setFont:[UIFont systemFontOfSize:kChannelLastMessageFontSize]];
    [self.lastMessageLabel setTextColor:UIColorFromRGB(0x999999)];
    [self addSubview:self.lastMessageLabel];
    
    self.bottomLineView = [[UIView alloc] init];
    [self.bottomLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomLineView setBackgroundColor:UIColorFromRGB(0xc8c8c8)];
    [self addSubview:self.bottomLineView];
    
    self.lastMessageDateLabel = [[UILabel alloc] init];
    [self.lastMessageDateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.lastMessageDateLabel setFont:[UIFont systemFontOfSize:kChannelLastMessageDateFontSize]];
    [self.lastMessageDateLabel setTextColor:UIColorFromRGB(0x999999)];
    [self.lastMessageDateLabel setText:@"Apr 16, 2015"];
    [self addSubview:self.lastMessageDateLabel];
    
    self.unreadCountImageView = [[UIImageView alloc] init];
    [self.unreadCountImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.unreadCountImageView setImage:[UIImage imageNamed:@"_bg_notify"]];
    [self addSubview:self.unreadCountImageView];
    
    self.unreadCountLabel = [[UILabel alloc] init];
    [self.unreadCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.unreadCountLabel setFont:[UIFont systemFontOfSize:kChannelUnreadCountFontSize]];
    [self.unreadCountLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.unreadCountLabel setText:@"99"];
    [self addSubview:self.unreadCountLabel];
    
    self.checkImageView = [[UIImageView alloc] init];
    [self.checkImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.checkImageView setImage:[UIImage imageNamed:@"_btn_check_off"]];
    [self addSubview:self.checkImageView];
    
    self.memberCountImageView = [[UIImageView alloc] init];
    [self.memberCountImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.memberCountImageView setImage:[UIImage imageNamed:@"_icon_group_number" ]];
    [self addSubview:self.memberCountImageView];
    
    self.memberCountLabel = [[UILabel alloc] init];
    [self.memberCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.memberCountLabel setText:@"5"];
    [self.memberCountLabel setTextColor:UIColorFromRGB(0xa4acbc)];
    [self.memberCountLabel setFont:[UIFont systemFontOfSize:10.0]];
    //    [self.memberCountLabel setBackgroundColor:[UIColor redColor]];
    [self addSubview:self.memberCountLabel];
    
    
    // Profile Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:40]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.profileImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:40]];
    
    // Nickname Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.profileImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:14]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.memberCountImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-10]];
    
    // Last Message Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:6]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.profileImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:14]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-46]];
    
    // Last Message Date
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageDateLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageDateLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-12]];
    
    // Unread Count Background Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadCountImageView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadCountImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadCountImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:22]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadCountImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:22]];
    
    // Unread Count Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadCountLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.unreadCountImageView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadCountLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.unreadCountImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    // Bottom Line View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLineView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLineView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:66]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLineView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLineView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:0.5]];
    
    // Check Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    // Member Count View
    // Member Count ImageView
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-70]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.nicknameLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:12.5]];
    memberCountImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.memberCountImageView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1 constant:22];
    [self addConstraint:memberCountImageViewWidthConstraint];
    // Member Count Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.memberCountImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.memberCountImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
}

- (void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self.checkImageView setImage:[UIImage imageNamed:@"_btn_check_on"]];
    }
    else {
        [self.checkImageView setImage:[UIImage imageNamed:@"_btn_check_off"]];
    }
}

- (void) setModel:(SendBirdMessagingChannel *)model withCheckMark:(BOOL)check
{
    if (model == nil) {
        return;
    }
    
    SendBirdMemberInMessagingChannel *member = nil;
    if ([[model members] count] > 0) {
        member = [[model members] objectAtIndex:0];
    }
    
    NSString *channelName = [NSString stringWithFormat:@"%@", [SendBirdUtils getMessagingChannelNames:[model members]]];
    [self.nicknameLabel setText:channelName];
    [self.lastMessageLabel setText:[[model lastMessage] message]];
    
    if (check) {
        [self.unreadCountLabel setHidden:YES];
        [self.unreadCountImageView setHidden:YES];
        [self.lastMessageDateLabel setHidden:YES];
        [self.checkImageView setHidden:NO];
    }
    else {
        [self.checkImageView setHidden:YES];
        if ([model lastMessage] == nil) {
            [self.lastMessageDateLabel setHidden:YES];
        }
        else {
            [self.lastMessageDateLabel setHidden:NO];
            long long ts = [[model lastMessage] getMessageTimestamp] / 1000;
            [self.lastMessageDateLabel setText:[SendBirdUtils lastMessageDateTime:ts]];
        }
        
        int unreadCount = [model unreadMessageCount];
        if (unreadCount > 0) {
            [self.unreadCountImageView setHidden:NO];
            [self.unreadCountLabel setHidden:NO];
            NSString *unreadCountText = @"";
            if (unreadCount < 99) {
                unreadCountText = [NSString stringWithFormat:@"%d", unreadCount];
            }
            else {
                unreadCountText = @"99";
            }
            [self.unreadCountLabel setText:unreadCountText];
        }
        else {
            [self.unreadCountImageView setHidden:YES];
            [self.unreadCountLabel setHidden:YES];
        }
    }
    
    [SendBirdUtils loadImage:[SendBirdUtils getDisplayCoverImageUrl:[model members]] imageView:self.profileImageView width:40 height:40];

    if ([[model members] count] > 2) {
        [self.memberCountLabel setHidden:NO];
        [self.memberCountImageView setHidden:NO];
        NSString *memberCount = [NSString stringWithFormat:@"%lu", (unsigned long)[[model members] count]];
        
        [self.memberCountLabel setText:memberCount];
        CGRect memberCountRect;
        NSMutableDictionary *memberCountAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:10.0], NSFontAttributeName, nil];
        NSAttributedString *attributedMemberCount = [[NSAttributedString alloc] initWithString:memberCount attributes:memberCountAttribute];
        memberCountRect = [attributedMemberCount boundingRectWithSize:CGSizeMake(INT64_MAX, 12.5) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
        
        memberCountImageViewWidthConstraint.constant = 16 + memberCountRect.size.width;
        [self updateConstraints];
    }
    else {
        [self.memberCountLabel setHidden:YES];
        [self.memberCountImageView setHidden:YES];
    }
}

@end
