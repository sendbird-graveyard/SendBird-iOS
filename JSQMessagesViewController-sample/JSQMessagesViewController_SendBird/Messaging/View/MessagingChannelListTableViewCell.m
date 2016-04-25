//
//  MessagingChannelListTableViewCell.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "MessagingChannelListTableViewCell.h"

@interface MessagingChannelListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *channelTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessageCountLabel;

@property (strong) SendBirdMessagingChannel *channel;

@end

@implementation MessagingChannelListTableViewCell

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

- (void)setModel:(SendBirdMessagingChannel *)aChannel
{
    self.channel = aChannel;
    
    [self.coverImageView setImageWithURL:[NSURL URLWithString:[self.channel getCoverUrl]]];
    [self.channelTitleLabel setText:[self.channel getUrl]];
    if ([[self.channel lastMessage] isKindOfClass:[SendBirdMessage class]]) {
        [self.lastMessageLabel setText:[(SendBirdMessage *)[self.channel lastMessage] message]];
    }
    else if ([[self.channel lastMessage] isKindOfClass:[SendBirdFileLink class]]) {
        [self.lastMessageLabel setText:@"(File)"];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.channel getLastMessageTimestamp]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [self.lastMessageDateLabel setText:[formatter stringFromDate:date]];

    if ([self.channel unreadMessageCount] == 0) {
        [self.unreadMessageCountLabel setHidden:YES];
    }
    else {
        [self.unreadMessageCountLabel setHidden:NO];
        [self.unreadMessageCountLabel setText:[NSString stringWithFormat:@"%d", self.channel.unreadMessageCount]];
    }
}

- (void)drawRect:(CGRect)rect {
    self.coverImageView.layer.cornerRadius = 18;
    self.coverImageView.clipsToBounds = YES;
}


@end
