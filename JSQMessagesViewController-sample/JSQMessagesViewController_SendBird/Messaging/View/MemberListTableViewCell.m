//
//  MemberListTableViewCell.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MemberListTableViewCell.h"

@interface MemberListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong) SendBirdAppUser *user;

@end

@implementation MemberListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setModel:(SendBirdAppUser *)aUser
{
    self.user = aUser;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.picture]];
    [self.usernameLabel setText:self.user.nickname];
}

- (void)drawRect:(CGRect)rect {
    self.profileImageView.layer.cornerRadius = 16;
    self.profileImageView.clipsToBounds = YES;
}

@end
