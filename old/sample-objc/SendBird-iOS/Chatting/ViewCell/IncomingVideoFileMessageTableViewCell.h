//
//  IncomingVideoFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 3/14/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "MessageDelegate.h"

@interface IncomingVideoFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) id<MessageDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDFileMessage *)aMessage;
- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (CGFloat)getHeightOfViewCell;

@end
