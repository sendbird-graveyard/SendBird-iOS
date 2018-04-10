//
//  OutgoingFileMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "MessageDelegate.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+ImageCache.h"

@interface OutgoingImageFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;

@property (weak, nonatomic, nullable) id<MessageDelegate> delegate;
@property (atomic) BOOL hasImageCacheData;

+ (nullable UINib *)nib;
+ (nullable NSString *)cellReuseIdentifier;
- (void)setModel:(SBDFileMessage * _Nonnull)message channel:(SBDBaseChannel *)channel;
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
