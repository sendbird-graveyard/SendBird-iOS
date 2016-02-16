//
//  SystemMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "SystemMessageTableViewCell.h"

#define kSystemMessageCellLeftMargin 16
#define kSystemMessageCellRightMargin 16
#define kSystemMessageCellGapMargin 10

@implementation SystemMessageTableViewCell

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
    
    self.leftLineView = [[UIView alloc] init];
    [self.leftLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.leftLineView setBackgroundColor:UIColorFromRGB(0xa6b0ba)];
    
    self.rightLineView = [[UIView alloc] init];
    [self.rightLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rightLineView setBackgroundColor:UIColorFromRGB(0xa6b0ba)];
    
    self.messageLabel = [[UILabel alloc] init];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setTextColor:UIColorFromRGB(0xa6b0ba)];
    [self.messageLabel setFont:[UIFont systemFontOfSize:11.0]];
    [self.messageLabel sizeToFit];
    
    [self addSubview:self.leftLineView];
    [self addSubview:self.rightLineView];
    [self addSubview:self.messageLabel];
    
    [self applyConstraints];
}

- (void) applyConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLineView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:kSystemMessageCellLeftMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLineView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageLabel
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-kSystemMessageCellGapMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLineView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLineView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:0.5]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLineView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-kSystemMessageCellRightMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLineView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.messageLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:kSystemMessageCellGapMargin]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLineView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLineView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:0.5]];
}

- (void) setModel:(SendBirdSystemMessage *)model
{
    NSString *s = [[NSString alloc] initWithString:[model message]];
    NSRange r;
    
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    [self.messageLabel setText:s];
}

@end