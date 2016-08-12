//
//  MessagingIndicatorView.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//
#import "MessagingIndicatorView.h"

@implementation MessagingIndicatorView

- (id) init
{
    self = [super init];
    if (self != nil) {
        [self initView];
    }
    return self;
}

- (void) initView
{
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    
    self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.progressView startAnimating];
    [self.progressView setColor:[UIColor whiteColor]];
    [self addSubview:self.progressView];
    
    [self applyConstraints];
    
}

- (void) applyConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
}

@end
