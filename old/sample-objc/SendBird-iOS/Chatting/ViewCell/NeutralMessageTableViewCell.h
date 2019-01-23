//
//  NeutralMessageTableViewCell.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/22/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface NeutralMessageTableViewCell : UITableViewCell

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;
- (void)setModel:(SBDAdminMessage *)aMessage;
- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage;
- (CGFloat)getHeightOfViewCell;

@end
