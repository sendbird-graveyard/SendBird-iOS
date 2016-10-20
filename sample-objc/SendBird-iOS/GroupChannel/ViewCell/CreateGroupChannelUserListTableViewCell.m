//
//  CreateGroupChannelUserListTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CreateGroupChannelUserListTableViewCell.h"

@interface CreateGroupChannelUserListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@property (strong, nonatomic) SBDUser *user;

@end

@implementation CreateGroupChannelUserListTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setModel:(SBDUser *)aUser {
    self.user = aUser;
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    self.nicknameLabel.text = self.user.nickname;
}

- (void)setSelectedUser:(BOOL)selected {
    if (selected) {
        [self.checkImageView setImage:[UIImage imageNamed:@"btn_check_on"]];
    }
    else {
        [self.checkImageView setImage:[UIImage imageNamed:@"btn_check_off"]];
    }
}

@end
