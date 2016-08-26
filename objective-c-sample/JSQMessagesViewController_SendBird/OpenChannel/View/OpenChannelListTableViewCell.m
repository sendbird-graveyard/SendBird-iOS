//
//  OpenChatListTableViewCell.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/25/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "OpenChannelListTableViewCell.h"

@interface OpenChannelListTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;

@property (strong) SBDOpenChannel *channel;

@end

@implementation OpenChannelListTableViewCell

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

- (void)setModel:(SBDOpenChannel *)aChannel
{
    self.channel = aChannel;
    
    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.channel.coverUrl]];
    [self.channelNameLabel setText:self.channel.name];
}

- (void)drawRect:(CGRect)rect {
    self.coverImageView.layer.cornerRadius = 16;
    self.coverImageView.clipsToBounds = YES;
}

@end
