//
//  MessagingChannelTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MessagingChannelTableViewCell : UITableViewCell

@property (retain) UIImageView *profileImageView;
@property (retain) UILabel *nicknameLabel;
@property (retain) UILabel *lastMessageLabel;
@property (retain) UIView *bottomLineView;
@property (retain) UIImageView *unreadCountImageView;
@property (retain) UILabel *unreadCountLabel;
@property (retain) UILabel *lastMessageDateLabel;
@property (retain) UIImageView *checkImageView;
@property (retain) UIImageView *memberCountImageView;
@property (retain) UILabel *memberCountLabel;

- (void) setModel:(SendBirdMessagingChannel *)model withCheckMark:(BOOL)check;

@end
