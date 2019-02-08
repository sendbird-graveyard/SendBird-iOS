//
//  GroupChannelListEditableTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GroupChannelListEditableTableViewCell.h"
#import "NSBundle+SendBird.h"

@interface GroupChannelListEditableTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *coverImageContainerForOne;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView11;
@property (weak, nonatomic) IBOutlet UIView *coverImageContainerForTwo;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView21;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView22;
@property (weak, nonatomic) IBOutlet UIView *coverImageContainerForThree;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView31;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView32;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView33;
@property (weak, nonatomic) IBOutlet UIView *coverImageContainerForFour;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView41;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView42;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView43;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView44;

@property (strong, nonatomic) SBDGroupChannel *channel;

@end

@implementation GroupChannelListEditableTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setModel:(SBDGroupChannel *)aChannel {
    self.channel = aChannel;
    
    self.memberCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.channel.memberCount];
    
    self.coverImageContainerForOne.hidden = YES;
    self.coverImageContainerForTwo.hidden = YES;
    self.coverImageContainerForThree.hidden = YES;
    self.coverImageContainerForFour.hidden = YES;
    
    NSMutableArray<NSString *> *memberNames = [[NSMutableArray alloc] init];
    if (self.channel.memberCount == 1) {
        self.coverImageContainerForOne.hidden = NO;
        
        SBDUser *member = self.channel.members[0];
        [self.coverImageView11 setImageWithURL:[NSURL URLWithString:member.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
        [memberNames addObject:member.nickname];
    }
    else if (self.channel.memberCount == 2) {
        self.coverImageContainerForOne.hidden = NO;
        
        for (SBDUser *member in self.channel.members) {
            if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            [self.coverImageView11 setImageWithURL:[NSURL URLWithString:member.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
            [memberNames addObject:member.nickname];
        }
    }
    else if (self.channel.memberCount == 3) {
        self.coverImageContainerForTwo.hidden = NO;
        
        NSArray<UIImageView *> *coverImages = @[self.coverImageView21, self.coverImageView22];
        NSMutableArray<SBDUser *> *memberExceptCurrentUser = [[NSMutableArray alloc] init];
        for (SBDUser *member in self.channel.members) {
            if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            
            [memberExceptCurrentUser addObject:member];
            [memberNames addObject:member.nickname];
        }
        
        for (int i = 0; i < memberExceptCurrentUser.count; i++) {
            [coverImages[i] setImageWithURL:[NSURL URLWithString:memberExceptCurrentUser[i].profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
        }
    }
    else if (self.channel.memberCount == 4) {
        self.coverImageContainerForThree.hidden = NO;
        
        NSArray<UIImageView *> *coverImages = @[self.coverImageView31, self.coverImageView32, self.coverImageView33];
        NSMutableArray<SBDUser *> *memberExceptCurrentUser = [[NSMutableArray alloc] init];
        for (SBDUser *member in self.channel.members) {
            if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            
            [memberExceptCurrentUser addObject:member];
            [memberNames addObject:member.nickname];
        }
        
        for (int i = 0; i < memberExceptCurrentUser.count; i++) {
            [coverImages[i] setImageWithURL:[NSURL URLWithString:memberExceptCurrentUser[i].profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
        }
    }
    else if (self.channel.memberCount > 4) {
        self.coverImageContainerForFour.hidden = NO;
        
        NSArray<UIImageView *> *coverImages = @[self.coverImageView41, self.coverImageView42, self.coverImageView43, self.coverImageView44];
        NSMutableArray<SBDUser *> *memberExceptCurrentUser = [[NSMutableArray alloc] init];
        int memberCount = 0;
        for (SBDUser *member in self.channel.members) {
            if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
                continue;
            }
            
            [memberExceptCurrentUser addObject:member];
            [memberNames addObject:member.nickname];
            
            memberCount += 1;
            if (memberCount >= 4) {
                break;
            }
        }
        
        for (int i = 0; i < 4; i++) {
            [coverImages[i] setImageWithURL:[NSURL URLWithString:memberExceptCurrentUser[i].profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
        }
    }
    
    self.channelNameLabel.text = [memberNames componentsJoinedByString:@", "];
    long long lastMessageTimestamp = 0;
    if ([self.channel.lastMessage isKindOfClass:[SBDUserMessage class]]) {
        SBDUserMessage *lastMessage = (SBDUserMessage *)self.channel.lastMessage;
        self.lastMessageLabel.text = lastMessage.message;
        lastMessageTimestamp = lastMessage.createdAt;
    }
    else if ([self.channel.lastMessage isKindOfClass:[SBDFileMessage class]]) {
        SBDFileMessage *lastMessage = (SBDFileMessage *)self.channel.lastMessage;
        if ([lastMessage.type hasPrefix:@"image"]) {
            self.lastMessageLabel.text = [NSBundle sbLocalizedStringForKey:@"MessageSummaryImage"];
        }
        else if ([lastMessage.type hasPrefix:@"video"]) {
            self.lastMessageLabel.text = [NSBundle sbLocalizedStringForKey:@"MessageSummaryVideo"];
        }
        else if ([lastMessage.type hasPrefix:@"audio"]) {
            self.lastMessageLabel.text = [NSBundle sbLocalizedStringForKey:@"MessageSummaryAudio"];
        }
        else {
            self.lastMessageLabel.text = [NSBundle sbLocalizedStringForKey:@"MessageSummaryFile"];
        }
        lastMessageTimestamp = lastMessage.createdAt;
    }
    else if ([self.channel.lastMessage isKindOfClass:[SBDAdminMessage class]]) {
        SBDAdminMessage *lastMessage = (SBDAdminMessage *)self.channel.lastMessage;
        self.lastMessageLabel.text = lastMessage.message;
        lastMessageTimestamp = lastMessage.createdAt;
    }
    else {
        self.lastMessageLabel.text = @"";
        lastMessageTimestamp = self.channel.createdAt;
    }
    
    // Last message date time
    NSDateFormatter *lastMessageDateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *lastMessageDate = nil;
    if ([NSString stringWithFormat:@"%lld", lastMessageTimestamp].length == 10) {
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastMessageTimestamp];
    }
    else {
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastMessageTimestamp / 1000.0];
    }
    NSDate *currDate = [NSDate date];
    
    NSDateComponents *lastMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:lastMessageDate];
    NSDateComponents *currDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currDate];
    
    if (lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day) {
        [lastMessageDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastMessageDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.dateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
    }
    else {
        [lastMessageDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [lastMessageDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.dateLabel.text = [lastMessageDateFormatter stringFromDate:lastMessageDate];
    }
}
@end
