//
//  IncomingTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "IncomingUserMessageTableViewCell.h"
#import "Constants.h"

@interface IncomingUserMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;

// Date Container Height
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateLabelContainerHeight;

// Message Date Label Width
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelWidth;

// Top Margin of Date Container
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerViewTopMargin;

// Left Margin of Profile Image
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageLeftMargin;

// Left Margin of Message Container
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftMargin;

// Profile Image Width
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageWidth;

// Message Container Padding
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerLeftPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerRightPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerTopPadding;

// Left Margin of Message Date
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelLeftMargin;

// Right Margin of Message Date
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageDateLabelRightMargin;

// Bottom Margin of Date Container
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerBottomMargin;

@property (strong, nonatomic) SBDUserMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (atomic) BOOL displayNickname;

@end

@implementation IncomingUserMessageTableViewCell

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

- (void)clickUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)setModel:(SBDUserMessage *)aMessage {
    self.message = aMessage;
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.message.sender.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    
    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    [profileImageTapRecognizer setDelegate:self];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:profileImageTapRecognizer];
    
    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserMessage)];
    self.messageContainerView.userInteractionEnabled = YES;
    [self.messageContainerView addGestureRecognizer:messageContainerTapRecognizer];
    
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
    self.dateSeperatorContainerView.hidden = NO;
    self.dateLabelContainerHeight.constant = 24.0;
    self.dateContainerViewTopMargin.constant = 10.0;
    self.dateContainerBottomMargin.constant = 10.0;
    self.displayNickname = YES;
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorContainerView.hidden = NO;
            self.dateLabelContainerHeight.constant = 24.0;
            self.dateContainerViewTopMargin.constant = 10.0;
            self.dateContainerBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorContainerView.hidden = YES;
            self.dateLabelContainerHeight.constant = 0;
            self.dateContainerBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateContainerViewTopMargin.constant = 10.0;
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
                
                if ([self.message isKindOfClass:[SBDUserMessage class]]) {
                    currMessageSender = [(SBDUserMessage *)self.message sender];
                }
                else if ([self.message isKindOfClass:[SBDFileMessage class]]) {
                    currMessageSender = [(SBDFileMessage *)self.message sender];
                }
                
                if (prevMessageSender != nil && currMessageSender != nil) {
                    if ([prevMessageSender.userId isEqualToString:currMessageSender.userId]) {
                        // Reduce margin
                        self.dateContainerViewTopMargin.constant = 5.0;
                        self.profileImageView.hidden = YES;
                        self.displayNickname = NO;
                    }
                    else {
                        // Set default margin.
                        self.profileImageView.hidden = NO;
                        self.dateContainerViewTopMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateContainerViewTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorContainerView.hidden = NO;
        self.dateLabelContainerHeight.constant = 24.0;
        self.dateContainerViewTopMargin.constant = 10.0;
        self.dateContainerBottomMargin.constant = 10.0;
    }
    
    NSAttributedString *fullMessage = [self buildMessage];
    [self.messageLabel setAttributedText:fullMessage];
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (NSAttributedString *)buildMessage {
    NSDictionary *nicknameAttribute = nil;
    switch(self.message.sender.nickname.length % 5) {
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

    NSDictionary *messageAttribute = @{
                                       NSFontAttributeName: [Constants messageFont],
                                       };
    
    NSString *nickname = self.message.sender.nickname;
    NSString *message = self.message.message;
    
    NSMutableAttributedString *fullMessage = nil;
    if (self.displayNickname) {
        fullMessage = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", nickname, message]];
        
        [fullMessage addAttributes:nicknameAttribute range:NSMakeRange(0, [nickname length])];
        [fullMessage addAttributes:messageAttribute range:NSMakeRange([nickname length] + 1, [message length])];
    }
    else {
        fullMessage = [[NSMutableAttributedString alloc] initWithString:message];
        [fullMessage addAttributes:messageAttribute range:NSMakeRange(0, [message length])];
    }
    
    return fullMessage;
}

- (CGFloat)getHeightOfViewCell {
    NSAttributedString *fullMessage = [self buildMessage];
    
    CGRect fullMessageRect;
    
    CGFloat messageLabelMaxWidth = self.frame.size.width - (self.profileImageLeftMargin.constant + self.profileImageWidth.constant + self.messageContainerLeftMargin.constant + self.messageContainerLeftPadding.constant + self.messageContainerRightPadding.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant + self.messageDateLabelRightMargin.constant);
    fullMessageRect = [fullMessage boundingRectWithSize:CGSizeMake(messageLabelMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGFloat cellHeight = self.dateContainerViewTopMargin.constant + self.dateLabelContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageRect.size.height + self.messageContainerBottomPadding.constant;
    
    return cellHeight;
}

@end
