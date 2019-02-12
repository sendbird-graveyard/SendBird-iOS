//
//  IncomingImageFileMessageTableViewCell.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "MessageDelegate.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+ImageCache.h"

@interface IncomingImageFileMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;

@property (weak, nonatomic) id<MessageDelegate> delegate;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDFileMessage *)aMessage;
- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (CGFloat)getHeightOfViewCell;

@end
