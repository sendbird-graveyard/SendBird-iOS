//
//  GroupChannelListTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface GroupChannelListTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)startTypingAnimation;
- (void)setModel:(SBDGroupChannel *)aChannel;

@end
