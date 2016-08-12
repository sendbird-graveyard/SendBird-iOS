//
//  ChannelTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file should be compiled with ARC enabled
#endif

#import "ChannelTableViewCell.h"

#define kChannelUrlFontSize 14.0
#define kChannelMembersFontSize 11.0
#define kChannelCoverRadius 19.0

@implementation ChannelTableViewCell

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
    self.coverImageView = [[UIImageView alloc] init];
    [self.coverImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.coverImageView.layer setCornerRadius:kChannelCoverRadius];
    [self.coverImageView setClipsToBounds:YES];
    [self.coverImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:self.coverImageView];
    
    self.channelUrlLabel = [[UILabel alloc] init];
    [self.channelUrlLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.channelUrlLabel setFont:[UIFont boldSystemFontOfSize:kChannelUrlFontSize]];
    [self.channelUrlLabel setTextColor:UIColorFromRGB(0x414858)];
    [self addSubview:self.channelUrlLabel];
    
    self.memberCountLabel = [[UILabel alloc] init];
    [self.memberCountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.memberCountLabel setFont:[UIFont systemFontOfSize:kChannelMembersFontSize]];
    [self.memberCountLabel setTextColor:UIColorFromRGB(0xa6b0ba)];
    [self addSubview:self.memberCountLabel];
    
    self.checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_icon_check"]];
    [self.checkImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.checkImageView setHidden:YES];
    [self addSubview:self.checkImageView];
    
    self.bottomLineView = [[UIView alloc] init];
    [self.bottomLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomLineView setBackgroundColor:UIColorFromRGB(0xd9d9d9)];
    [self addSubview:self.bottomLineView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:15]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:38]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:38]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.channelUrlLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:6]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.channelUrlLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.coverImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:15]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.channelUrlLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-46]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-6]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.coverImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:15]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.memberCountLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-46]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-15]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:22]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:22]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLineView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLineView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.coverImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:15]];
    
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
                                                    multiplier:1 constant:1]];
}

- (void) setModel:(SendBirdChannel *)model
{
    if (model == nil) {
        return;
    }
    
    [self.channelUrlLabel setText:[NSString stringWithFormat:@"#%@",[SendBirdUtils getChannelNameFromUrl:[model url]]]];
    if ([model memberCount] <= 1) {
        [self.memberCountLabel setText:[NSString stringWithFormat:@"%d MEMBER", [model memberCount]]];
    }
    else {
        [self.memberCountLabel setText:[NSString stringWithFormat:@"%d MEMBERS", [model memberCount]]];
    }
    
    if ([[SendBird getCurrentChannel] channelId] == [model channelId]) {
        [self setBackgroundColor:UIColorFromRGB(0xffffe2)];
        [self.checkImageView setHidden:NO];
    }
    else {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.checkImageView setHidden:YES];
    }

    [SendBirdUtils loadImage:[model coverUrl] imageView:self.coverImageView width:38 height:38];
}

@end
