//
//  ChannelTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface ChannelTableViewCell : UITableViewCell

@property (retain) UILabel *channelUrlLabel;
@property (retain) UILabel *memberCountLabel;
@property (retain) UIImageView *coverImageView;
@property (retain) UIImageView *checkImageView;
@property (retain) UIView *bottomLineView;

- (void) setModel:(SendBirdChannel *)model;

@end
