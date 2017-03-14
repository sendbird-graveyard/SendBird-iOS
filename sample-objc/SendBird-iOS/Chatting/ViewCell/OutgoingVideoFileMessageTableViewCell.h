//
//  OutgoingVideoFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Gyeong on 3/14/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "MessageDelegate.h"

@interface OutgoingVideoFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) id<MessageDelegate> delegate;

+ (nullable UINib *)nib;
+ (nullable NSString *)cellReuseIdentifier;
- (void)setModel:(SBDFileMessage * _Nonnull)message;
- (void)setPreviousMessage:(SBDBaseMessage * _Nullable)aPrevMessage;
- (CGFloat)getHeightOfViewCell;
- (void)hideUnreadCount;
- (void)showUnreadCount;
- (void)hideMessageControlButton;
- (void)showMessageControlButton;
- (void)showSendingStatus;
- (void)showFailedStatus;
- (void)showMessageDate;

@end
