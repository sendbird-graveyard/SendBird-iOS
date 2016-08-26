//
//  MessagingChannelListTableViewCell.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "GroupChannelListTableViewCell.h"

@interface GroupChannelListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *channelTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessageCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberCountLabel;

@property (strong) SBDGroupChannel *channel;

@end

@implementation GroupChannelListTableViewCell

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

- (void)setModel:(SBDGroupChannel *)aChannel
{
    self.channel = aChannel;

    SBDUser *representativeUser = nil;

    NSString *channelTitle = @"";
    NSMutableArray<NSString *> *channelTitleNameArray = [[NSMutableArray alloc] init];
    for (SBDUser *user in self.channel.members) {
        if ([user.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            continue;
        }
        else {
            [channelTitleNameArray addObject:user.nickname];
            representativeUser = user;
        }
    }
    
    if (representativeUser != nil) {
        [self.coverImageView setImageWithURL:[NSURL URLWithString:representativeUser.profileUrl]];
    }
    else {
        [self.coverImageView setImageWithURL:[NSURL URLWithString:self.channel.coverUrl]];
    }
    
    channelTitle = [channelTitleNameArray componentsJoinedByString:@","];

    [self.channelTitleLabel setText:channelTitle];
    NSDate *date = nil;
    if ([[self.channel lastMessage] isKindOfClass:[SBDUserMessage class]]) {
        [self.lastMessageLabel setText:[(SBDUserMessage *)[self.channel lastMessage] message]];
        date = [NSDate dateWithTimeIntervalSince1970:([[self.channel lastMessage] createdAt] / 1000)];
    }
    else if ([[self.channel lastMessage] isKindOfClass:[SBDFileMessage class]]) {
        [self.lastMessageLabel setText:@"(File)"];
        date = [NSDate dateWithTimeIntervalSince1970:([[self.channel lastMessage] createdAt] / 1000)];
    }
    else {
        [self.lastMessageLabel setText:@""];
        date = [NSDate dateWithTimeIntervalSince1970:([self.channel createdAt] / 1000)];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [self.lastMessageDateLabel setText:[formatter stringFromDate:date]];

    if ([self.channel unreadMessageCount] == 0) {
        [self.unreadMessageCountLabel setHidden:YES];
    }
    else {
        [self.unreadMessageCountLabel setHidden:NO];
        [self.unreadMessageCountLabel setText:[NSString stringWithFormat:@"%lu", self.channel.unreadMessageCount]];
    }
    
    [self.memberCountLabel setText:[NSString stringWithFormat:@"%lu", self.channel.memberCount]];
}

- (void)drawRect:(CGRect)rect {
    self.coverImageView.layer.cornerRadius = 18;
    self.coverImageView.clipsToBounds = YES;
}


@end
