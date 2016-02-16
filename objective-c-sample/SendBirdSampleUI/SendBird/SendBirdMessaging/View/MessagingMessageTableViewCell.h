//
//  MessagingMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SendBirdCommon.h"

@interface MessagingMessageTableViewCell : UITableViewCell

@property (retain) SendBirdMessage *message;
@property (retain) UIImageView *profileImageView;
@property (retain) UIImageView *messageBackgroundImageView;
@property (retain) UILabel *nicknameLabel;
@property (retain) UILabel *messageLabel;
@property (retain) UILabel *dateTimeLabel;

- (void) setContinuousMessage:(BOOL)continuousFlag;
- (void) setModel:(SendBirdMessage *)message;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
