//
//  MessagingFileLinkTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MessagingFileLinkTableViewCell : UITableViewCell

@property (retain) SendBirdFileLink *fileLink;
@property UIImageView *profileImageView;
@property UIImageView *fileImageView;
@property UIImageView *messageBackgroundImageView;
@property (retain) UILabel *nicknameLabel;
@property (retain) UILabel *dateTimeLabel;

- (void) setModel:(SendBirdFileLink *)model;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end

