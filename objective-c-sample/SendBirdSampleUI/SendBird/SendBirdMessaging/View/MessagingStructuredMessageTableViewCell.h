//
//  MessagingStructuredMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 10. 15..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MessagingStructuredMessageTableViewCell : UITableViewCell

@property (retain) SendBirdStructuredMessage *message;
@property UIImageView *profileImageView;
//@property UIImageView *fileImageView;
@property UIImageView *messageBackgroundImageView;
@property (retain) UILabel *nicknameLabel;
@property (retain) UILabel *dateTimeLabel;

@property (retain) UIImageView *thumbImageView;
@property (retain) UILabel *titleLabel;
@property (retain) UILabel *descLabel;
@property (retain) UIView *dividerView;
@property (retain) UIImageView *structuredIconImageView;
@property (retain) UILabel *structuredNameLabel;
@property (retain) UIImageView *structuredBotImageView;

- (void) setModel:(SendBirdStructuredMessage *)model;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
