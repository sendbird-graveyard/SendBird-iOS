//
//  MessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MessageTableViewCell : UITableViewCell

@property (retain) SendBirdMessage *message;
@property (retain) UILabel *messageLabel;

- (void) setModel:(SendBirdMessage *)message;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
