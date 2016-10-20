//
//  OutgoingUserMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/22/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "MessageDelegate.h"

@interface OutgoingUserMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) id<MessageDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDUserMessage *)aMessage;
- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (CGFloat)getHeightOfViewCell;
- (void)hideUnreadCount;
- (void)showUnreadCount;
- (void)hideMessageControlButton;
- (void)showMessageControlButton;

@end
