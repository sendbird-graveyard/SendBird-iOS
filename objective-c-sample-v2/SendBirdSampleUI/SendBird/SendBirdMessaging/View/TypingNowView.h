//
//  TypingNowView.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface TypingNowView : UIView

@property (retain) UIImageView *typingImageView;
@property (retain) UILabel *typingLabel;

- (id) initWithFrame:(CGRect)frame;
- (void) setModel:(NSDictionary *)typeStatus;

@end
