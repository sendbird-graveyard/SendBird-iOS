//
//  MessagingMyStructuredMessageTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 10. 15..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MessagingMyStructuredMessageTableViewCell : UITableViewCell

@property (retain) SendBirdStructuredMessage *message;
@property (retain) UIImageView *messageBackgroundImageView;
@property (retain) UIImageView *thumbImageView;
@property (retain) UILabel *titleLabel;
@property (retain) UILabel *descLabel;
@property (retain) UIView *dividerView;
@property (retain) UILabel *dateTimeLabel;
@property (retain) UILabel *unreadLabel;
@property (retain) NSMutableDictionary *readStatus;
@property (retain) UIImageView *structuredIconImageView;
@property (retain) UILabel *structuredNameLabel;
@property (retain) UIImageView *structuredBotImageView;

- (void) setContinuousMessage:(BOOL)continuousFlag;
- (void) setModel:(SendBirdStructuredMessage *)message;
- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth;

@end
