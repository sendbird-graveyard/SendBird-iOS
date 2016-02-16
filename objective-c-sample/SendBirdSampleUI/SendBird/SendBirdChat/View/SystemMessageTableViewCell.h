//
//  SystemMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface SystemMessageTableViewCell : UITableViewCell

@property (retain) UIView *leftLineView;
@property (retain) UIView *rightLineView;
@property (retain) UILabel *messageLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setModel:(SendBirdSystemMessage *)model;

@end
