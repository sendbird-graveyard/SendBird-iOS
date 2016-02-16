//
//  BroadcastMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface BroadcastMessageTableViewCell : UITableViewCell

@property (retain) SendBirdBroadcastMessage *message;
@property (retain) UILabel *messageLabel;
@property (retain) UIView *innerView;

- (void) setModel:(SendBirdBroadcastMessage *)message;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
