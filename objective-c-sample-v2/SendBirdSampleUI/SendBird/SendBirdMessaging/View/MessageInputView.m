//
//  MessageInputView.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "MessageInputView.h"

#define kMessageFontSize 14.0
#define kMessageSendButtonFontSize 11.0

@implementation MessageInputView {
    BOOL inputEnabled;
    NSLayoutConstraint *textViewHeight;
    NSLayoutConstraint *sendButtonHeight;
    NSLayoutConstraint *fileAttachButtonHeight;
}

@synthesize delegate = _delegate;

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
    inputEnabled = YES;
    
    [self setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    self.topLineView = [[UIView alloc] init];
    [self.topLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.topLineView setBackgroundColor:UIColorFromRGB(0xbfbfbf)];
    
    self.openChannelListButton = [[UIButton alloc] init];
    [self.openChannelListButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.openChannelListButton setImage:[UIImage imageNamed:@"_btn_channel_list"] forState:UIControlStateNormal];
    [self.openChannelListButton addTarget:nil action:@selector(clickChannelListButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.messageTextView = [[UITextView alloc] init];
    [self.messageTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageTextView setTextColor:UIColorFromRGB(0x37434f)];
    [self.messageTextView setFont:[UIFont systemFontOfSize:kMessageFontSize]];
    [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(6, 8, 6, 8)];
    [self.messageTextView.layer setBorderWidth:1.0];
    [self.messageTextView.layer setBorderColor:[UIColorFromRGB(0xbbc3c9) CGColor]];
    [self.messageTextView setBackgroundColor:[UIColor whiteColor]];
    
    self.fileAttachButton = [[UIButton alloc] init];
    [self.fileAttachButton setBackgroundColor:[UIColor clearColor]];
    [self.fileAttachButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.fileAttachButton setImage:[UIImage imageNamed:@"_sendbird_btn_upload_off"] forState:UIControlStateNormal];
    [self.fileAttachButton setImage:[UIImage imageNamed:@"_sendbird_btn_upload_on"] forState:UIControlStateHighlighted];
    [self.fileAttachButton setImage:[UIImage imageNamed:@"_sendbird_btn_upload_on"] forState:UIControlStateSelected];
    [self.fileAttachButton addTarget:nil action:@selector(clickFileAttachButton) forControlEvents:UIControlEventTouchUpInside];
    [self.fileAttachButton.layer setBorderWidth:1.0];
    [self.fileAttachButton.layer setBorderColor:[UIColorFromRGB(0xbbc3c9) CGColor]];
    
    self.sendButton = [[UIButton alloc] init];
    [self.sendButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kMessageSendButtonFontSize]];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"_btn_green"] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"_btn_green"] forState:UIControlStateHighlighted];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"_btn_green"] forState:UIControlStateSelected];
    [self.sendButton addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton.layer setBorderWidth:1.0];
    [self.sendButton.layer setBorderColor:[UIColorFromRGB(0xbbc3c9) CGColor]];
    [self.sendButton setEnabled:NO];
    
    [self addSubview:self.topLineView];
    [self addSubview:self.openChannelListButton];
    [self addSubview:self.messageTextView];
    [self addSubview:self.fileAttachButton];
    [self addSubview:self.sendButton];
    
    
    [self applyConstraints];
}

- (void) applyConstraints
{
    // Top Line View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topLineView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topLineView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topLineView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topLineView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:1]];
    
    // Channel List Button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.openChannelListButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.openChannelListButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.openChannelListButton
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.openChannelListButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:15]];
    
    // File Attach Button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:28]];
    fileAttachButtonHeight = [NSLayoutConstraint constraintWithItem:self.fileAttachButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:30];
    [self addConstraint:fileAttachButtonHeight];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-1]];
    
    // Message TextField
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-7]];
    textViewHeight = [NSLayoutConstraint constraintWithItem:self.messageTextView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1 constant:30];
    [self addConstraint:textViewHeight];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.sendButton
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:1]];
    
    // Send Button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1 constant:-7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:40]];
    sendButtonHeight = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:1 constant:30];
    [self addConstraint:sendButtonHeight];
}

- (void)clickSendButton:(id)sender
{
    if ([[self.messageTextView text] length] == 0) {
        return;
    }
    [[self delegate] clickSendButton:[self.messageTextView text]];
    [SendBird typeEnd];
}

- (void)setHeight:(CGFloat)currentHeight maxHeight:(CGFloat)maxHeight
{
    if (currentHeight > 30 && currentHeight < maxHeight) {
        textViewHeight.constant = currentHeight;
        fileAttachButtonHeight.constant = currentHeight;
        sendButtonHeight.constant = currentHeight;
    }
    else if (currentHeight > maxHeight) {
        textViewHeight.constant = maxHeight;
        fileAttachButtonHeight.constant = maxHeight;
        sendButtonHeight.constant = maxHeight;
    }
    else {
        textViewHeight.constant = 30;
        fileAttachButtonHeight.constant = 30;
        sendButtonHeight.constant = 30;
    }
    
    [self.messageTextView updateConstraints];
}

- (void)hideSendButton
{
    [self.sendButton setEnabled:NO];
}

- (void)showSendButton
{
    [self.sendButton setEnabled:YES];
}

- (void)clickFileAttachButton
{
    [[self delegate] clickFileAttachButton];
}

- (void)clickChannelListButton
{
    [[self delegate] clickChannelListButton];
}

- (void)hideKeyboard
{
    [self.messageTextView endEditing:YES];
}

- (void) setDelegate:(id<MessageInputViewDelegate, UITextViewDelegate>)delegate
{
    _delegate = delegate;
    [self.messageTextView setDelegate:delegate];
}

//- (void) textFieldDidChange:(UITextView *)textView
//{
//    if ([[textView text] length] > 0) {
//        if ([self.sendButton alpha] == 0) {
//            [UILabel beginAnimations:nil context:nil];
//            [UILabel setAnimationDuration:0.3];
//            [self.sendButton setAlpha:1];
//            [UILabel commitAnimations];
//            [self.sendButton setEnabled:YES];
//        }
//        [SendBird typeStart];
//    }
//    else {
//        [UILabel beginAnimations:nil context:nil];
//        [UILabel setAnimationDuration:0.3];
//        [self.sendButton setAlpha:0];
//        [UILabel commitAnimations];
//        [self.sendButton setEnabled:NO];
//        [SendBird typeEnd];
//    }
//}

- (void) setInputEnable:(BOOL)enable
{
    [self.fileAttachButton setEnabled:enable];
    [self.messageTextView setEditable:enable];
    [self.sendButton setEnabled:enable];
}

- (BOOL) isInputEnable
{
    return inputEnabled;
}

@end
