//
//  MemberTableViewCell.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"

@interface MemberTableViewCell : UITableViewCell

@property (retain) UIImageView *profileImageView;
@property (retain) UILabel *nicknameLabel;
@property (retain) UIView *seperateLineView;
@property (retain) UIImageView *checkImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setModel:(SendBirdAppUser *)model withCheckMark:(BOOL)check;

@end
