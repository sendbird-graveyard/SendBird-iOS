//
//  OutgoingGeneralUrlPreviewTempMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 3/17/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "OutgoingGeneralUrlPreviewTempModel.h"

@interface OutgoingGeneralUrlPreviewTempMessageTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(OutgoingGeneralUrlPreviewTempModel *)aMessage;
- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (CGFloat)getHeightOfViewCell;

@end
