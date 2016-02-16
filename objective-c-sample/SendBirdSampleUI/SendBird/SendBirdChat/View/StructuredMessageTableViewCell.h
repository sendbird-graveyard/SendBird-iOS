//
//  StructuredMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 10. 14..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface StructuredMessageTableViewCell : UITableViewCell

@property (retain) SendBirdStructuredMessage *structuredMessage;
@property (retain) UIView *cellView;
@property (retain) UILabel *titleLabel;
@property (retain) UIImageView *thumbImageView;
@property (retain) UILabel *descLabel;
@property (retain) UIView *dividerView;
@property (retain) UIImageView *structuredIconImageView;
@property (retain) UILabel *structuredNameLabel;

- (void) setModel:(SendBirdStructuredMessage *)model;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
