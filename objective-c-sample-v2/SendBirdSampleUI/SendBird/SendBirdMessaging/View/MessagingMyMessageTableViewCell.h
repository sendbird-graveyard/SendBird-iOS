//
//  MessagingMyMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MessagingMyMessageTableViewCell : UITableViewCell

@property (retain) SendBirdMessage *message;
@property (retain) UIImageView *messageBackgroundImageView;
@property (retain) UILabel *messageLabel;
@property (retain) UILabel *dateTimeLabel;
@property (retain) UILabel *unreadLabel;
@property (retain) NSMutableDictionary *readStatus;

- (void) setContinuousMessage:(BOOL)continuousFlag;
- (void) setModel:(SendBirdMessage *)message;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
