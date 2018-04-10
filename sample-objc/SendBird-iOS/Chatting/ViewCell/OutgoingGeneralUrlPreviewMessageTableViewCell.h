//
//  OutgoingGeneralUrlPreviewMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jebeom Gyeong on 16/03/2017.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "MessageDelegate.h"

@interface OutgoingGeneralUrlPreviewMessageTableViewCell : UITableViewCell<TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *previewThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *previewThumbnailImageLoadingIndicator;
@property (strong, nonatomic) NSDictionary *previewData;

@property (weak, nonatomic) id<MessageDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDUserMessage *)aMessage channel:(SBDBaseChannel *)channel;
- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (CGFloat)getHeightOfViewCell;
- (void)hideUnreadCount;
- (void)showUnreadCount;
- (void)hideMessageControlButton;
- (void)showMessageControlButton;
- (void)showSendingStatus;
- (void)showFailedStatus;
- (void)showMessageDate;

@end
