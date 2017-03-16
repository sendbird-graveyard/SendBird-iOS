//
//  OutgoingFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "MessageDelegate.h"

@interface OutgoingImageFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) id<MessageDelegate> delegate;
@property (atomic) BOOL hasImageCacheData;

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
- (void)setImageData:(NSData * _Nonnull)imageData type:(NSString * _Nullable)type;

@end
