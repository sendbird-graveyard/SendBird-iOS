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
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenAtLabel;

@property (strong) SBDUser *user;

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

- (void)setModel:(SBDUser *)aUser
{
    self.user = aUser;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.profileUrl]];
    [self.usernameLabel setText:self.user.nickname];
    
    if (self.user.connectionStatus == SBDUserConnectionStatusOnline) {
        [self.onlineStatusLabel setText:@"Online"];
        [self.onlineStatusLabel setTextColor:[UIColor greenColor]];
    }
    else {
        [self.onlineStatusLabel setText:@"Offline"];
        [self.onlineStatusLabel setTextColor:[UIColor grayColor]];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(self.user.lastSeenAt / 1000)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [self.lastSeenAtLabel setText:[formatter stringFromDate:date]];
}

- (void)setOnlineStatusVisiblility:(BOOL)visibility {
    [self.onlineStatusLabel setHidden:!visibility];
    [self.lastSeenAtLabel setHidden:!visibility];
}

- (void)drawRect:(CGRect)rect {
    self.profileImageView.layer.cornerRadius = 16;
    self.profileImageView.clipsToBounds = YES;
}

@end
