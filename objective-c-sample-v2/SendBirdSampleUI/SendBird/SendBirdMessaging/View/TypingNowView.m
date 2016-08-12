//
//  TypingNowView.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "TypingNowView.h"

@implementation TypingNowView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initView];
    }
    return self;
}

- (void) initView
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.typingImageView = [[UIImageView alloc] init];
    [self.typingImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.typingImageView.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"_icon_loading_typing0"],
                                            [UIImage imageNamed:@"_icon_loading_typing1"],
                                            [UIImage imageNamed:@"_icon_loading_typing2"],
                                            [UIImage imageNamed:@"_icon_loading_typing3"],
                                            [UIImage imageNamed:@"_icon_loading_typing4"],
                                            [UIImage imageNamed:@"_icon_loading_typing5"],
                                            [UIImage imageNamed:@"_icon_loading_typing6"], nil];
    
    self.typingImageView.animationDuration = 1.0f;
    self.typingImageView.animationRepeatCount = 0;
    [self.typingImageView startAnimating];
    [self addSubview:self.typingImageView];
    
    self.typingLabel = [[UILabel alloc] init];
    [self.typingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.typingLabel setFont:[UIFont italicSystemFontOfSize:12.0]];
    [self.typingLabel setNumberOfLines:0];
    [self.typingLabel setTextColor:UIColorFromRGB(0x9d9ba5)];
    [self.typingLabel setText:@"Typing something cool...."];
    [self.typingLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self addSubview:self.typingLabel];
    
    // Typing Image View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingImageView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.typingLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingImageView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.typingLabel
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:18.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingImageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:5]];
    
    // Typing Label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:10]];
}

- (void) setModel:(NSDictionary *)typeStatus
{
    int count = (int)[typeStatus count];
    [self.typingLabel setText:[NSString stringWithFormat:@"%d Typing something cool....", count]];
}

@end
