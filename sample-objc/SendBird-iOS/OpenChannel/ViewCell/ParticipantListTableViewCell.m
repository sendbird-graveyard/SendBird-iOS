//
//  ParticipantListTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ParticipantListTableViewCell.h"

@interface ParticipantListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) SBDUser *user;

@end

@implementation ParticipantListTableViewCell

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

@end
