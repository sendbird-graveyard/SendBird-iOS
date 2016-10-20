//
//  OpenChannelListTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "OpenChannelListTableViewCell.h"
#import "Constants.h"
#import "NSBundle+SendBird.h"

@interface OpenChannelListTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *leftLineView;
@property (weak, nonatomic) IBOutlet UILabel *channelName;
@property (weak, nonatomic) IBOutlet UILabel *participantCountLabel;

@end

@implementation OpenChannelListTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setRow:(NSUInteger)row {
    switch (row % 5) {
        case 0:
            self.leftLineView.backgroundColor = [Constants openChannelLineColorNo0];
            break;
            
        case 1:
            self.leftLineView.backgroundColor = [Constants openChannelLineColorNo1];
            break;
            
        case 2:
            self.leftLineView.backgroundColor = [Constants openChannelLineColorNo2];
            break;
            
        case 3:
            self.leftLineView.backgroundColor = [Constants openChannelLineColorNo3];
            break;
            
        case 4:
            self.leftLineView.backgroundColor = [Constants openChannelLineColorNo4];
            break;
            
        default:
            self.leftLineView.backgroundColor = [Constants openChannelLineColorNo0];
            break;
    }
}

- (void)setModel:(SBDOpenChannel *)aChannel {
    self.channelName.text = aChannel.name;
    if (aChannel.participantCount <= 1) {
        self.participantCountLabel.text = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"ParticipantSingular"], aChannel.participantCount];
    }
    else {
        self.participantCountLabel.text = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"ParticipantPlural"], aChannel.participantCount];
    }
}

@end
