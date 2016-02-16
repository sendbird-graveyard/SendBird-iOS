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
    
    
    self.messageTextField = [[UITextField alloc] init];
    [self.messageTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageTextField setReturnKeyType:UIReturnKeyDone];
    [self.messageTextField setPlaceholder:@"What\'s on your mind?"];
    [self.messageTextField setTextColor:UIColorFromRGB(0x37434f)];
    [self.messageTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"What\'s on your mind?" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0xbbc3c9)}]];
    [self.messageTextField setFont:[UIFont systemFontOfSize:kMessageFontSize]];
    UIView *paddingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    UIView *paddingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 8)];
    [self.messageTextField setLeftView:paddingLeftView];
    [self.messageTextField setRightView:paddingRightView];
    [self.messageTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.messageTextField setRightViewMode:UITextFieldViewModeAlways];
    [self.messageTextField.layer setBorderWidth:1.0];
    [self.messageTextField.layer setBorderColor:[UIColorFromRGB(0xbbc3c9) CGColor]];
    [self.messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
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
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"_btn_white_line"] forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setAlpha:0];
    [self.sendButton setEnabled:NO];
    
    [self addSubview:self.openChannelListButton];
    [self addSubview:self.messageTextField];
    [self addSubview:self.fileAttachButton];
    [self addSubview:self.sendButton];
    [self addSubview:self.topLineView];
    
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
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:28]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextField
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.fileAttachButton
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-1]];
    
    // Message TextField
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextField
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextField
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextField
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:-10]];
    
    // Send Button
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1 constant:30]];
}

- (void)clickSendButton:(id)sender
{
    if ([[self.messageTextField text] length] == 0) {
        return;
    }
    [[self delegate] clickSendButton:[self.messageTextField text]];
    [SendBird typeEnd];
}

- (void)hideSendButton
{
    [UILabel beginAnimations:nil context:nil];
    [UILabel setAnimationDuration:0.3];
    [self.sendButton setAlpha:0];
    [UILabel commitAnimations];
    [self.sendButton setEnabled:NO];
}

- (void)showSendButton
{
    [self.sendButton setAlpha:1];
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
    [self.messageTextField endEditing:YES];
}

- (void) setDelegate:(id<MessageInputViewDelegate, UITextFieldDelegate>)delegate
{
    _delegate = delegate;
    [self.messageTextField setDelegate:delegate];
}

- (void) textFieldDidChange:(UITextView *)textView
{
    if ([[textView text] length] > 0) {
        if ([self.sendButton alpha] == 0) {
            [UILabel beginAnimations:nil context:nil];
            [UILabel setAnimationDuration:0.3];
            [self.sendButton setAlpha:1];
            [UILabel commitAnimations];
            [self.sendButton setEnabled:YES];
        }
        [SendBird typeStart];
    }
    else {
        [UILabel beginAnimations:nil context:nil];
        [UILabel setAnimationDuration:0.3];
        [self.sendButton setAlpha:0];
        [UILabel commitAnimations];
        [self.sendButton setEnabled:NO];
        [SendBird typeEnd];
    }
}

- (void) setInputEnable:(BOOL)enable
{
    [self.fileAttachButton setEnabled:enable];
    [self.messageTextField setEnabled:enable];
    [self.sendButton setEnabled:enable];
}

- (BOOL) isInputEnable
{
    return inputEnabled;
}

@end
