//
//  IncomingFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "IncomingFileMessageTableViewCell.h"
#import "Constants.h"

@interface IncomingFileMessageTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerTopMargin;

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fileActionImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

@property (strong, nonatomic) SBDFileMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation IncomingFileMessageTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)clickProfileImage {
    if (self.delegate != nil) {
        [self.delegate clickProfileImage:self user:self.message.sender];
    }
}

- (void)clickFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)setModel:(SBDFileMessage *)aMessage {
    self.message = aMessage;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.message.sender.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    
    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:profileImageTapRecognizer];
    
    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.messageContainerView.userInteractionEnabled = YES;
    [self.messageContainerView addGestureRecognizer:messageContainerTapRecognizer];
    
    if ([self.message.type hasPrefix:@"video"]) {
        [self.fileTypeImageView setImage:[UIImage imageNamed:@"icon_video_chat"]];
        [self.fileActionImageView setImage:[UIImage imageNamed:@"btn_play_chat"]];
    }
    else if ([self.message.type hasPrefix:@"audio"]) {
        [self.fileTypeImageView setImage:[UIImage imageNamed:@"icon_voice_chat"]];
        [self.fileActionImageView setImage:[UIImage imageNamed:@"btn_play_chat"]];
    }
    else {
        [self.fileTypeImageView setImage:[UIImage imageNamed:@"icon_file_chat"]];
        [self.fileActionImageView setImage:[UIImage imageNamed:@"btn_download_chat"]];
    }
    
    NSDictionary *nicknameAttribute = nil;
    switch (self.message.sender.nickname.length % 5) {
        case 0:
            nicknameAttribute = @{
                                  NSFontAttributeName: [Constants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [Constants nicknameColorInMessageNo0]
                                  };
            break;
        case 1:
            nicknameAttribute = @{
                                  NSFontAttributeName: [Constants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [Constants nicknameColorInMessageNo1]
                                  };
            break;
        case 2:
            nicknameAttribute = @{
                                  NSFontAttributeName: [Constants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [Constants nicknameColorInMessageNo2]
                                  };
            break;
        case 3:
            nicknameAttribute = @{
                                  NSFontAttributeName: [Constants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [Constants nicknameColorInMessageNo3]
                                  };
            break;
        case 4:
            nicknameAttribute = @{
                                  NSFontAttributeName: [Constants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [Constants nicknameColorInMessageNo4]
                                  };
            break;
        default:
            nicknameAttribute = @{
                                  NSFontAttributeName: [Constants nicknameFontInMessage],
                                  NSForegroundColorAttributeName: [Constants nicknameColorInMessageNo0]
                                  };
            break;
    }
    
    self.nicknameLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:self.message.sender.nickname attributes:nicknameAttribute];
    self.filenameLabel.text = self.message.name;
    
    // Message Date
    NSDictionary *messageDateAttribute = @{
                                           NSFontAttributeName: [Constants messageDateFont],
                                           NSForegroundColorAttributeName: [Constants messageDateColor]
                                           };
    
    NSTimeInterval messageTimestamp = (double)self.message.createdAt / 1000.0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageTimestamp];
    NSString *messageDateString = [dateFormatter stringFromDate:messageCreatedDate];
    NSMutableAttributedString *messageDateAttributedString = [[NSMutableAttributedString alloc] initWithString:messageDateString attributes:messageDateAttribute];
    self.messageDateLabel.attributedText = messageDateAttributedString;
    
    // Seperator Date
    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateSeperatorLabel.text = [seperatorDateFormatter stringFromDate:messageCreatedDate];

    // Relationship between the current message and the previous message
    self.profileImageView.hidden = NO;
    self.nicknameLabelHeight.constant = 19.0;
    self.nicknameLabelBottomMargin.constant = 10.0;
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorContainerView.hidden = NO;
            self.dateContainerHeight.constant = 24.0;
            self.dateContainerTopMargin.constant = 10.0;
            self.dateContainerBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorContainerView.hidden = YES;
            self.dateContainerHeight.constant = 0;
            self.dateContainerBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateContainerTopMargin.constant = 10.0;
            }
            else {
                SBDUser *prevMessageSender = nil;
                SBDUser *currMessageSender = nil;
                
                if ([self.prevMessage isKindOfClass:[SBDUserMessage class]]) {
                    prevMessageSender = [(SBDUserMessage *)self.prevMessage sender];
                }
                else if ([self.prevMessage isKindOfClass:[SBDFileMessage class]]) {
                    prevMessageSender = [(SBDFileMessage *)self.prevMessage sender];
                }
                
                currMessageSender = [self.message sender];
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.dateContainerTopMargin.constant = 5.0;
                        self.profileImageView.hidden = YES;
                        self.nicknameLabelHeight.constant = 0;
                        self.nicknameLabelBottomMargin.constant = 0;
                    }
                    else {
                        // Set default margin.
                        self.profileImageView.hidden = NO;
                        self.dateContainerTopMargin.constant = 10.0;
                        self.nicknameLabelHeight.constant = 19.0;
                        self.nicknameLabelBottomMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateContainerTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorContainerView.hidden = NO;
        self.dateContainerHeight.constant = 24.0;
        self.dateContainerTopMargin.constant = 10.0;
        self.dateContainerBottomMargin.constant = 10.0;
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (CGFloat)getHeightOfViewCell {
    CGFloat height = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + self.nicknameLabelHeight.constant + self.nicknameLabelBottomMargin.constant + self.fileContainerHeight.constant + self.messageContainerBottomPadding.constant;
    
    return height;
}

@end
