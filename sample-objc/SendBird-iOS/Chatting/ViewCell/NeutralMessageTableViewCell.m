//
//  NeutralMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/22/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "NeutralMessageTableViewCell.h"
#import "Constants.h"

@interface NeutralMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

// For Cell Height
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewTopPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconImageViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewBottomPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerViewBottomMargin;

// For Label Width
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewLeftPadding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageContainerViewRightPadding;

@property (strong, nonatomic) SBDAdminMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;

@end

@implementation NeutralMessageTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setModel:(SBDAdminMessage *)aMessage {
    self.message = aMessage;
    
    NSAttributedString *fullMessage = [self buildMessage];
    [self.messageLabel setAttributedText:fullMessage];
    
    // Seperator Date
    NSTimeInterval messageTimestamp = (double)self.message.createdAt / 1000.0;
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageTimestamp];

    NSDateFormatter *seperatorDateFormatter = [[NSDateFormatter alloc] init];
    [seperatorDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateSeperatorLabel.text = [seperatorDateFormatter stringFromDate:messageCreatedDate];
    
    // Relationship between the current message and the previous message
    self.dateSeperatorContainerView.hidden = NO;
    self.dateContainerHeight.constant = 24.0;
    self.dateContainerViewTopMargin.constant = 10.0;
    self.dateContainerViewBottomMargin.constant = 10.0;
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
            self.dateContainerViewTopMargin.constant = 10.0;
            self.dateContainerViewBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorContainerView.hidden = YES;
            self.dateContainerHeight.constant = 0;
            self.dateContainerViewBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateContainerViewTopMargin.constant = 5.0;
            }
            else {
                self.dateContainerViewTopMargin.constant = 10.0;
            }
        }
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (NSAttributedString *)buildMessage {
    NSDictionary *messageAttribute = @{
                                       NSFontAttributeName: [Constants messageFont]
                                       };
    
    NSString *message = self.message.message;
    
    NSMutableAttributedString *fullMessage = [[NSMutableAttributedString alloc] initWithString:message];
    
    [fullMessage addAttributes:messageAttribute range:NSMakeRange(0, [message length])];
    
    return fullMessage;
}


- (CGFloat)getHeightOfViewCell {
    NSAttributedString *fullMessage = [self buildMessage];
    
    CGRect fullMessageRect;
    
    CGFloat messageLabelMaxWidth = self.frame.size.width - (self.messageContainerViewLeftMargin.constant + self.messageContainerViewRightMargin.constant + self.messageContainerViewLeftPadding.constant + self.messageContainerViewRightPadding.constant);
    fullMessageRect = [fullMessage boundingRectWithSize:CGSizeMake(messageLabelMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGFloat cellHeight = self.dateContainerViewTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerViewBottomMargin.constant + self.messageContainerViewTopPadding.constant + self.iconImageViewHeight.constant + self.iconImageViewBottomMargin.constant + fullMessageRect.size.height + self.messageContainerViewBottomPadding.constant;
    
    return cellHeight;
}

@end
