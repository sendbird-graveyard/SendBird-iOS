//
//  MessagingChannelListTableViewCell.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MessagingChannelListTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDGroupChannel *)aChannel;

@end
