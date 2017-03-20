//
//  IncomingGeneralUrlPreviewMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jebeom Gyeong on 16/03/2017.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "IncomingGeneralUrlPreviewMessageTableViewCell.h"
#import "FLAnimatedImage.h"
#import "AppDelegate.h"
#import "FLAnimatedImageView+ImageCache.h"
#import "Constants.h"

@interface IncomingGeneralUrlPreviewMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *previewThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *previewSiteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *previewThumbnailLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dividerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dividerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewSiteNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewSiteNameBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewDescriptionBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbnailImageHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewDescriptionWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewThumbnailImageWidth;

@property (strong, nonatomic) SBDUserMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;
@property (strong, nonatomic) NSDictionary *previewData;
@property (atomic) BOOL displayNickname;

@end

@implementation IncomingGeneralUrlPreviewMessageTableViewCell

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
    
    NSData *data = [self.message.data dataUsingEncoding:NSUTF8StringEncoding];
    self.previewData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *imageUrl = self.previewData[@"image"];
    NSString *ext = [imageUrl pathExtension];
    NSString *siteName = self.previewData[@"site_name"];
    NSString *title = self.previewData[@"title"];
    NSString *description = self.previewData[@"description"];
    
    self.previewThumbnailImageView.image = nil;
    self.previewThumbnailImageView.animatedImage = nil;
    self.previewThumbnailLoadingIndicator.hidden = NO;
    [self.previewThumbnailLoadingIndicator startAnimating];
    if (imageUrl != nil && imageUrl.length > 0) {
        if ([[ext lowercaseString] hasPrefix:@"gif"]) {
            [self.previewThumbnailImageView setAnimatedImageWithURL:[NSURL URLWithString:imageUrl] success:^(FLAnimatedImage * _Nullable image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.previewThumbnailImageView.image = nil;
                    self.previewThumbnailImageView.animatedImage = nil;
                    [self.previewThumbnailImageView setAnimatedImage:image];
                    self.previewThumbnailLoadingIndicator.hidden = YES;
                    [self.previewThumbnailLoadingIndicator stopAnimating];
                });
            } failure:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.previewThumbnailLoadingIndicator.hidden = YES;
                    [self.previewThumbnailLoadingIndicator stopAnimating];
                });
            }];
        }
        else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
            [self.previewThumbnailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.previewThumbnailImageView setImage:image];
                    self.previewThumbnailLoadingIndicator.hidden = YES;
                    [self.previewThumbnailLoadingIndicator stopAnimating];
                });
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.previewThumbnailLoadingIndicator.hidden = YES;
                    [self.previewThumbnailLoadingIndicator stopAnimating];
                });
            }];
        }
    }
    else {
        self.previewThumbnailImageView.hidden = YES;
        self.previewThumbnailLoadingIndicator.hidden = YES;
        self.previewThumbnailImageHeight.constant = 0;
        self.previewDescriptionBottomMargin.constant = 10;
    }
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.message.sender.profileUrl] placeholderImage:[UIImage imageNamed:@"img_profile"]];
    
    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    [profileImageTapRecognizer setDelegate:self];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:profileImageTapRecognizer];
    
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
    self.dateSeperatorView.hidden = NO;
    self.dateSeperatorHeight.constant = 24.0;
    self.dateSeperatorTopMargin.constant = 10.0;
    self.dateSeperatorBottomMargin.constant = 10.0;
    self.displayNickname = YES;
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorView.hidden = NO;
            self.dateSeperatorHeight.constant = 24.0;
            self.dateSeperatorTopMargin.constant = 10.0;
            self.dateSeperatorBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorView.hidden = YES;
            self.dateSeperatorHeight.constant = 0;
            self.dateSeperatorBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateSeperatorTopMargin.constant = 10.0;
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
                        self.dateSeperatorTopMargin.constant = 5.0;
                        self.profileImageView.hidden = YES;
                        self.displayNickname = NO;
                    }
                    else {
                        // Set default margin.
                        self.profileImageView.hidden = NO;
                        self.dateSeperatorTopMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateSeperatorTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorView.hidden = NO;
        self.dateSeperatorHeight.constant = 24.0;
        self.dateSeperatorTopMargin.constant = 10.0;
        self.dateSeperatorBottomMargin.constant = 10.0;
    }
    
    self.previewSiteNameLabel.text = siteName;
    self.previewTitleLabel.text = title;
    self.previewDescriptionLabel.text = description;
    
    NSAttributedString *fullMessage = [self buildMessage];
    self.messageLabel.attributedText = fullMessage;
    self.messageLabel.userInteractionEnabled = YES;
    self.messageLabel.linkAttributes = @{
                                         NSFontAttributeName: [Constants messageFont],
                                         NSForegroundColorAttributeName: [Constants incomingMessageColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                         };
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error == nil) {
        NSArray *matches = [detector matchesInString:self.message.message options:0 range:NSMakeRange(0, self.message.message.length)];
        if (matches.count > 0) {
            self.messageLabel.delegate = self;
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            for (NSTextCheckingResult *match in matches) {
                NSRange rangeOfOriginalMessage = [match range];
                NSRange range;
                if (self.displayNickname == YES) {
                    range = NSMakeRange(self.message.sender.nickname.length + 1 + rangeOfOriginalMessage.location, rangeOfOriginalMessage.length);
                }
                else {
                    range = rangeOfOriginalMessage;
                }

                [self.messageLabel addLinkToURL:[match URL] withRange:range];
            }
        }
    }
    
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
    CGRect fullMessageRect = [fullMessage boundingRectWithSize:CGSizeMake(self.messageWidth.constant, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    NSDictionary *attributes = @{NSFontAttributeName: [Constants urlPreviewDescriptionFont]};
    NSString *description = self.previewData[@"description"];
    CGRect descriptionRect = [description boundingRectWithSize:CGSizeMake(self.previewDescriptionWidth.constant, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGFloat cellHeight = self.dateSeperatorTopMargin.constant + self.dateSeperatorHeight.constant + self.dateSeperatorBottomMargin.constant + self.messageTopMargin.constant + fullMessageRect.size.height + self.messageBottomMargin.constant + self.dividerHeight.constant + self.dividerBottomMargin.constant + self.previewSiteNameHeight.constant + self.previewSiteNameBottomMargin.constant + self.previewTitleHeight.constant + self.previewTitleBottomMargin.constant + descriptionRect.size.height + self.previewDescriptionBottomMargin.constant + self.previewThumbnailImageHeight.constant;

    return cellHeight;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
