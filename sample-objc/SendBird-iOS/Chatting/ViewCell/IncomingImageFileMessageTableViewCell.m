//
//  IncomingImageFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "IncomingImageFileMessageTableViewCell.h"
#import "Utils.h"
#import "Constants.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView+ImageCache.h"

@interface IncomingImageFileMessageTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *dateSeperatorView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSeperatorViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageHeight;

@property (strong, nonatomic) SBDFileMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation IncomingImageFileMessageTableViewCell

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
    self.fileImageView.userInteractionEnabled = YES;
    [self.fileImageView addGestureRecognizer:messageContainerTapRecognizer];

    self.imageLoadingIndicator.hidden = NO;
    [self.imageLoadingIndicator startAnimating];
    self.fileImageView.animatedImage = nil;
    self.fileImageView.image = nil;

    __block NSString *url = self.message.url;
    if (self.message.type != nil && [self.message.type isEqualToString:@"image/gif"] ) {
        /***********************************/
        /* Thumbnail is a premium feature. */
        /***********************************/
        if (self.message.thumbnails != nil && self.message.thumbnails.count > 0) {
            if (self.message.thumbnails[0].url.length > 0) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.message.thumbnails[0].url]];
                [self.fileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.fileImageView setImage:image];
                        self.imageLoadingIndicator.hidden = YES;
                        [self.imageLoadingIndicator stopAnimating];
                        
                        [self.fileImageView setAnimatedImageWithURL:[NSURL URLWithString:url] success:^(FLAnimatedImage * _Nullable image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.fileImageView setAnimatedImage:image];
                                
                            });
                        } failure:^(NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                            });
                        }];
                    });
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageLoadingIndicator.hidden = YES;
                        [self.imageLoadingIndicator stopAnimating];
                    });
                }];
            }
        }
        else {
            [self.fileImageView setAnimatedImageWithURL:[NSURL URLWithString:url] success:^(FLAnimatedImage * _Nullable image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.fileImageView setAnimatedImage:image];
                    self.imageLoadingIndicator.hidden = YES;
                    [self.imageLoadingIndicator stopAnimating];
                });
            } failure:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageLoadingIndicator.hidden = YES;
                    [self.imageLoadingIndicator stopAnimating];
                });
            }];
        }
    }
    else {
        /***********************************/
        /* Thumbnail is a premium feature. */
        /***********************************/
        if (self.message.thumbnails != nil && self.message.thumbnails.count > 0) {
            if (self.message.thumbnails[0].url.length > 0) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.message.thumbnails[0].url]];
                [self.fileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.fileImageView setImage:image];
                        self.imageLoadingIndicator.hidden = YES;
                        [self.imageLoadingIndicator stopAnimating];
                    });
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageLoadingIndicator.hidden = YES;
                        [self.imageLoadingIndicator stopAnimating];
                    });
                }];
            }
        }
        else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.message.url]];
            [self.fileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.fileImageView setImage:image];
                    self.imageLoadingIndicator.hidden = YES;
                    [self.imageLoadingIndicator stopAnimating];
                });
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageLoadingIndicator.hidden = YES;
                    [self.imageLoadingIndicator stopAnimating];
                });
            }];
        }
    }

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
    if (self.prevMessage != nil) {
        // Day Changed
        NSDate *prevMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.prevMessage.createdAt / 1000.0];
        NSDate *currMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)self.message.createdAt / 1000.0];
        NSDateComponents *prevMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:prevMessageDate];
        NSDateComponents *currMessageDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currMessageDate];
        
        if (prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day) {
            // Show date seperator.
            self.dateSeperatorView.hidden = NO;
            self.dateSeperatorViewHeight.constant = 24.0;
            self.dateSeperatorViewTopMargin.constant = 10.0;
            self.dateSeperatorViewBottomMargin.constant = 10.0;
        }
        else {
            // Hide date seperator.
            self.dateSeperatorView.hidden = YES;
            self.dateSeperatorViewHeight.constant = 0;
            self.dateSeperatorViewBottomMargin.constant = 0;
            
            // Continuous Message
            if ([self.prevMessage isKindOfClass:[SBDAdminMessage class]]) {
                self.dateSeperatorViewTopMargin.constant = 10.0;
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
                        self.dateSeperatorViewTopMargin.constant = 5.0;
                        self.profileImageView.hidden = YES;
                    }
                    else {
                        // Set default margin.
                        self.profileImageView.hidden = NO;
                        self.dateSeperatorViewTopMargin.constant = 10.0;
                    }
                }
                else {
                    self.dateSeperatorViewTopMargin.constant = 10.0;
                }
            }
        }
    }
    else {
        // Show date seperator.
        self.dateSeperatorView.hidden = NO;
        self.dateSeperatorViewHeight.constant = 24.0;
        self.dateSeperatorViewTopMargin.constant = 10.0;
        self.dateSeperatorViewBottomMargin.constant = 10.0;
    }
    
    [self layoutIfNeeded];
}

- (void)setPreviousMessage:(SBDBaseMessage *)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (CGFloat)getHeightOfViewCell {
    CGFloat height = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.fileImageHeight.constant;
    
    return height;
}

@end
