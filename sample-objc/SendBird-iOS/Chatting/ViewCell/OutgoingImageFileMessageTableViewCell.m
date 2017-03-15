//
//  OutgoingFileMessageTableViewCell.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "OutgoingImageFileMessageTableViewCell.h"
#import "Utils.h"
#import "Constants.h"
#import "FLAnimatedImage.h"
#import "AppDelegate.h"

@interface OutgoingImageFileMessageTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateContainerTopMargin;
@property (weak, nonatomic) IBOutlet UILabel *sendStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *resendMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteMessageButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountLabel;
@property (weak, nonatomic) IBOutlet UIView *dateSeperatorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *dateSeperatorLabel;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;

@property (strong, nonatomic) SBDFileMessage *message;
@property (strong, nonatomic) SBDBaseMessage *prevMessage;

@end

@implementation OutgoingImageFileMessageTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)clickFileMessage {
    if (self.delegate != nil) {
        [self.delegate clickMessage:self message:self.message];
    }
}

- (void)clickResendUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickResend:self message:self.message];
    }
}

- (void)clickDeleteUserMessage {
    if (self.delegate != nil) {
        [self.delegate clickDelete:self message:self.message];
    }
}

- (void)setModel:(SBDFileMessage *)aMessage {
    self.message = aMessage;
    
    self.imageLoadingIndicator.hidden = YES;
    self.fileImageView.animatedImage = nil;
    self.fileImageView.image = nil;
    __block NSString *url = self.message.url;
    if (self.message.url != nil && self.message.url.length > 0 && self.message.type != nil && [self.message.type isEqualToString:@"image/gif"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FLAnimatedImage *cachedImageData = (FLAnimatedImage *)[FLAnimatedImage animatedImageWithGIFData:[[AppDelegate imageCache] objectForKey:url]];
            if (cachedImageData != nil) {
                [self.fileImageView setAnimatedImage:cachedImageData];
            }
            else {
                [self.fileImageView setAnimatedImage:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageLoadingIndicator.hidden = NO;
                    [self.imageLoadingIndicator startAnimating];
                });
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error != nil) {
                        // TODO: Show download failed.
                        [session invalidateAndCancel];
                        
                        return;
                    }
                    
                    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                    if ([resp statusCode] >= 200 && [resp statusCode] < 300) {
                        __block FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                        [[AppDelegate imageCache] setObject:data forKey:url];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.fileImageView setAnimatedImage:animatedImage];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.imageLoadingIndicator.hidden = YES;
                                [self.imageLoadingIndicator stopAnimating];
                            });
                        });
                    }
                    else {
                        // TODO: Show download failed.
                    }
                    
                    [session invalidateAndCancel];
                }] resume];

//                dispatch_queue_t imageLoadQueue = dispatch_queue_create("com.sendbird.imageloadqueue", NULL);
//                dispatch_async(imageLoadQueue, ^{
//                    __block NSData *cachedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//                    __block FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:cachedData];
//                    
//                    if ([[AppDelegate imageCache] objectForKey:url] == nil) {
//                        [[AppDelegate imageCache] setObject:cachedData forKey:url];
//                    }
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.fileImageView setAnimatedImage:animatedImage];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            self.imageLoadingIndicator.hidden = YES;
//                            [self.imageLoadingIndicator stopAnimating];
//                        });
//                    });
//                });
            }
        });
    }
    else {
        /***********************************/
        /* Thumbnail is a premium feature. */
        /***********************************/
        if (self.message.thumbnails != nil && self.message.thumbnails.count > 0) {
            if (self.message.thumbnails[0].url.length > 0) {
                [self.fileImageView setImageWithURL:[NSURL URLWithString:self.message.thumbnails[0].url]];
            }
        }
        else {
            [self.fileImageView setImageWithURL:[NSURL URLWithString:self.message.url]];
        }
    }
    
    UITapGestureRecognizer *messageContainerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFileMessage)];
    self.fileImageView.userInteractionEnabled = YES;
    [self.fileImageView addGestureRecognizer:messageContainerTapRecognizer];
    
    [self.resendMessageButton addTarget:self action:@selector(clickResendUserMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteMessageButton addTarget:self action:@selector(clickDeleteUserMessage) forControlEvents:UIControlEventTouchUpInside];

    // Unread message count
    if ([self.message.channelType isEqualToString:CHANNEL_TYPE_GROUP]) {
        SBDGroupChannel *channelOfMessage = [SBDGroupChannel getChannelFromCacheWithChannelUrl:self.message.channelUrl];
        if (channelOfMessage != nil) {
            int unreadMessageCount = [channelOfMessage getReadReceiptOfMessage:self.message];
            if (unreadMessageCount == 0) {
                [self hideUnreadCount];
                self.unreadCountLabel.text = @"";
            }
            else {
                [self showUnreadCount];
                self.unreadCountLabel.text = [NSString stringWithFormat:@"%d", unreadMessageCount];
            }
        }
    }
    else {
        [self hideUnreadCount];
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
    self.dateSeperatorContainerView.hidden = NO;
    self.dateContainerHeight.constant = 24.0;
    self.dateContainerTopMargin.constant = 10.0;
    self.dateContainerBottomMargin.constant = 10.0;
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
                    }
                    else {
                        // Set default margin.
                        self.dateContainerTopMargin.constant = 10.0;
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

- (void)setPreviousMessage:(SBDBaseMessage * _Nullable)aPrevMessage {
    self.prevMessage = aPrevMessage;
}

- (CGFloat)getHeightOfViewCell {
    CGFloat height = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.fileImageHeight.constant;
    
    return height;
}

- (void)hideUnreadCount {
    self.unreadCountLabel.hidden = YES;
}

- (void)showUnreadCount {
    if ([self.message.channelType isEqualToString:CHANNEL_TYPE_GROUP]) {
        self.unreadCountLabel.hidden = NO;
        self.resendMessageButton.hidden = YES;
        self.deleteMessageButton.hidden = YES;
    }
}

- (void)hideMessageControlButton {
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
}

- (void)showMessageControlButton {
    self.sendStatusLabel.hidden = YES;
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    
    self.resendMessageButton.hidden = NO;
    self.deleteMessageButton.hidden = NO;
}

- (void)showSendingStatus {
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
    self.sendStatusLabel.hidden = NO;
    self.sendStatusLabel.text = @"Sending";
}

- (void)showFailedStatus {
    self.messageDateLabel.hidden = YES;
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.deleteMessageButton.hidden = YES;
    
    self.sendStatusLabel.hidden = NO;
    self.sendStatusLabel.text = @"Failed";
}

- (void)showMessageDate {
    self.unreadCountLabel.hidden = YES;
    self.resendMessageButton.hidden = YES;
    self.sendStatusLabel.hidden = YES;
    
    self.messageDateLabel.hidden = NO;
}

- (void)setImageData:(NSData * _Nonnull)imageData type:(NSString * _Nullable)type {
    if (type != nil && [type isEqualToString:@"image/gif"]) {
        dispatch_queue_t imageLoadQueue = dispatch_queue_create("com.sendbird.imageloadqueue", NULL);
        dispatch_async(imageLoadQueue, ^{
            __block FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.fileImageView setAnimatedImage:animatedImage];
            });
        });
    }
    else {
        [self.fileImageView setImage:[UIImage imageWithData:imageData]];
    }
}

@end
