//
//  GroupChannelListEditableTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface GroupChannelListEditableTableViewCell : MGSwipeTableCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDGroupChannel *)aChannel;

@end
