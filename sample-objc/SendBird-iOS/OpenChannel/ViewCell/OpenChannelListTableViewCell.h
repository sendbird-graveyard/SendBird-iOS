//
//  OpenChannelListTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface OpenChannelListTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setRow:(NSUInteger)row;
- (void)setModel:(SBDOpenChannel *)aChannel;

@end
