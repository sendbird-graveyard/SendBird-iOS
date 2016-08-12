//
//  MessagingMyFileLinkTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Develpers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MessagingMyFileLinkTableViewCell : UITableViewCell

@property (retain) SendBirdFileLink *fileLink;
@property (retain) SendBirdMessagingChannel *currentChannel;
@property UIImageView *messageBackgroundImageView;
@property (retain) UILabel *dateTimeLabel;
@property (retain) UILabel *unreadLabel;
@property UIImageView *fileImageView;
@property (retain) NSMutableDictionary *readStatus;

- (void) setContinuousMessage:(BOOL)continuousFlag;
- (void) setModel:(SendBirdFileLink *)model;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
