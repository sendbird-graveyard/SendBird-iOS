//
//  GroupChannelListTableViewCell.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GroupChannelListTableViewCell.h"
#import "NSBundle+SendBird.h"

@interface GroupChannelListTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessageCountLabel;
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
@property (weak, nonatomic) IBOutlet UIView *unreadMessageCountContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *typingImageView;
@property (weak, nonatomic) IBOutlet UILabel *typingLabel;

@property (strong, nonatomic) SBDGroupChannel *channel;

@end


@implementation GroupChannelListTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)startTypingAnimation {
    if (self.channel == nil) {
        return;
    }
    
    // Typing indicator
    if (self.channel.isTyping) {
        NSString *typingLabelText = @"";
        if (self.channel.getTypingMembers.count == 1) {
            typingLabelText = [NSString stringWithFormat:[NSBundle sbLocalizedStringForKey:@"TypingMessageSingular"], self.channel.getTypingMembers[0].nickname];
        }
        else {
            typingLabelText = [NSBundle sbLocalizedStringForKey:@"TypingMessagePlural"];
        }
        
        self.typingLabel.text = typingLabelText;
        
        if (self.typingImageView.animating == NO) {
            NSMutableArray<UIImage *> *typingImages = [[NSMutableArray alloc] init];
            for (int i = 1; i <= 50; i++) {
                NSString *typingImageFrameName = [NSString stringWithFormat:@"%02d", i];
                [typingImages addObject:[UIImage imageNamed:typingImageFrameName]];
            }
            self.typingImageView.animationImages = typingImages;
            self.typingImageView.animationDuration = 1.5;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.typingImageView startAnimating];
            });
        }
        self.lastMessageLabel.hidden = YES;
        self.typingImageView.hidden = NO;
        self.typingLabel.hidden = NO;
    }
    else {
        if (self.typingImageView.animating == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.typingImageView stopAnimating];
            });
        }
        self.lastMessageLabel.hidden = NO;
        self.typingImageView.hidden = YES;
        self.typingLabel.hidden = YES;
    }
}

- (void)setModel:(SBDGroupChannel *)aChannel {
    self.channel = aChannel;
    
    self.memberCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.channel.memberCount];
    
    self.typingImageView.hidden = YES;
    self.typingLabel.hidden = YES;
    
    self.coverImageContainerForOne.hidden = YES;
    self.coverImageContainerForTwo.hidden = YES;
    self.coverImageContainerForThree.hidden = YES;
    self.coverImageContainerForFour.hidden = YES;
    
    NSMutableArray<NSString *> *memberNames = [[NSMutableArray alloc] init];
    NSArray <UIImageView *> *memberImageViews;
    UIView *coverImageContainer;
    NSMutableArray<SBDMember *> *memberExceptCurrentUser = [[NSMutableArray alloc] init];
    
    for (SBDMember *member in self.channel.members) {
        if ([member.userId isEqualToString:[SBDMain getCurrentUser].userId]) {
            continue;
        }
        
        [memberExceptCurrentUser addObject:member];
        [memberNames addObject:member.nickname];
        
        if (memberExceptCurrentUser.count >= 10) {
            break;
        }
    }
    
    if (memberExceptCurrentUser.count == 1) {
        coverImageContainer = self.coverImageContainerForOne;
        [self.coverImageView11 setImageWithURL:[NSURL URLWithString:memberExceptCurrentUser.firstObject.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
        
        memberImageViews = @[self.coverImageView11];
    }
    else if (memberExceptCurrentUser.count == 2) {
        coverImageContainer = self.coverImageContainerForTwo;
        
        memberImageViews = @[self.coverImageView21, self.coverImageView22];
    }
    else if (memberExceptCurrentUser.count == 3) {
        coverImageContainer = self.coverImageContainerForThree;
        
        memberImageViews = @[self.coverImageView31, self.coverImageView32, self.coverImageView33];
    }
    else if (memberExceptCurrentUser.count >= 4) {
        coverImageContainer = self.coverImageContainerForFour;
        
        memberImageViews = @[self.coverImageView41, self.coverImageView42, self.coverImageView43, self.coverImageView44];
    }
    
    [memberImageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *profileUrlString = memberExceptCurrentUser[idx].profileUrl;
        NSURL *profileUrl = [NSURL URLWithString:profileUrlString];
        [obj setImageWithURL:profileUrl placeholderImage:[UIImage imageNamed:@"img_profile"]];
    }];
    
    if (memberExceptCurrentUser.count == 0 && [SBDMain getCurrentUser] != nil) {
        coverImageContainer = self.coverImageContainerForOne;
        [self.coverImageView11 setImageWithURL:[NSURL URLWithString:[SBDMain getCurrentUser].profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
        
        memberImageViews = @[self.coverImageView11];
        
        [memberNames removeAllObjects];
        [memberNames addObject:[NSBundle sbLocalizedStringForKey:@"EmptyChannelName"]];
    }
    
    coverImageContainer.hidden = NO;
    
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
    
    self.unreadMessageCountContainerView.hidden = NO;
    if (self.channel.unreadMessageCount == 0) {
        self.unreadMessageCountContainerView.hidden = YES;
    }
    else if (self.channel.unreadMessageCount <= 9) {
        self.unreadMessageCountLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.channel.unreadMessageCount];
    }
    else {
        self.unreadMessageCountLabel.text = @"9+";
    }
}

@end
