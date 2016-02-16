//
//  FileLinkTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "FileLinkTableViewCell.h"

#define kFileLinkTopMargin 4.0
#define kFileLinkBottomMargin 4.0
#define kFileLinkLeftMargin 15.0
#define kFileLinkRightMargin 15.0
#define kFileLinkFileNameFontSize 10.0
#define kFileLinkMessageFontSize 14.0
#define kFileLinkImageWidth 180.0
#define kFileLinkImageHeight 140.0
#define kFileLinkLeftBarWidth 3
#define kFileLinkLMarginBetweenMessageAndImageInfo 4
#define kFileLinkMarginBetweenLeftBarAndImage 6.0
#define kFileLinkMarginBetweenFilenameAndImage 6.0

@implementation FileLinkTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {
        [self initViews];
    }
    
    return self;
}

- (void) initViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.messageLabel = [[UILabel alloc] init];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setFont:[UIFont systemFontOfSize:kFileLinkMessageFontSize]];
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.messageLabel setNumberOfLines:0];
    
    self.fileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_icon_file"]];
    [self.fileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.fileImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.filenameLabel = [[UILabel alloc] init];
    [self.filenameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.filenameLabel setFont:[UIFont systemFontOfSize:kFileLinkFileNameFontSize]];
    [self.filenameLabel setTextColor:UIColorFromRGB(0x595959)];
    
    self.leftBarView = [[UIView alloc] init];
    [self.leftBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.leftBarView setBackgroundColor:UIColorFromRGB(0x000000)];
    [self.leftBarView setAlpha:0.15];
    
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.fileImageView];
    [self.contentView addSubview:self.filenameLabel];
    [self.contentView addSubview:self.leftBarView];
    
    // Message Label
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kFileLinkTopMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:kFileLinkLeftMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:-kFileLinkRightMargin]];
    
    // Left Bar View
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftBarView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:kFileLinkLeftMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.leftBarView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:-kFileLinkLMarginBetweenMessageAndImageInfo]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftBarView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileLinkLeftBarWidth]];
    
    // File Name
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:-kFileLinkLMarginBetweenMessageAndImageInfo]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.leftBarView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kFileLinkMarginBetweenLeftBarAndImage]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kFileLinkRightMargin]];
    
    // Image
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:kFileLinkMarginBetweenFilenameAndImage]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.leftBarView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kFileLinkMarginBetweenLeftBarAndImage]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileLinkImageWidth]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileLinkImageHeight]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.leftBarView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:0]];
    
    
    // Content View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1 constant:0]];
}

- (void) setModel:(SendBirdFileLink *)model
{
    self.fileLink = model;
    [self.messageLabel setAttributedText:[self buildMessage]];
    [self.filenameLabel setText:[[self.fileLink fileInfo] name]];
    
    if ([[[self.fileLink fileInfo] type] hasPrefix:@"image"]) {
        [SendBirdUtils loadImage:[[model fileInfo] url] imageView:self.fileImageView width:kFileLinkImageWidth height:kFileLinkImageHeight];
    }
}

- (NSAttributedString *)buildMessage
{
    NSMutableDictionary *nameAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:kFileLinkMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x824096), NSForegroundColorAttributeName, nil];
    NSMutableDictionary *messageAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kFileLinkMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x595959), NSForegroundColorAttributeName,nil];
    NSString *fileLinkUrl = [[self.fileLink fileInfo] url];
    if ([[[self.fileLink fileInfo] type] hasPrefix:@"image"]) {
        fileLinkUrl = @"";
    }
    NSString *message = [[NSString stringWithFormat:@"%@: %@", [[self.fileLink sender] name], fileLinkUrl] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    //    NSString *message = [[NSString stringWithFormat:@"%@: %@", [[self.fileLink sender] name], [[self.fileLink fileInfo] url]] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"\u2011"];
    message = [message stringByReplacingOccurrencesOfString:@"/" withString:@"\u2215"];
    
    int badge = 0;
    if ([self.fileLink isOpMessage]) {
        message = [NSString stringWithFormat:@"\u00A0\u00A0%@", message];
        badge = 2;
    }
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange nameRange = NSMakeRange(badge, [[[self.fileLink sender] name] length]);
    //    NSRange messageRange = NSMakeRange([[[self.fileLink sender] name] length] + badge, [[[self.fileLink fileInfo] url] length] + 2);
    NSRange messageRange = NSMakeRange([[[self.fileLink sender] name] length] + badge, [fileLinkUrl length] + 2);
    
    if ([self.fileLink isOpMessage]) {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"_icon_admin"];
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedMessage replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
    }
    
    [attributedMessage beginEditing];
    [attributedMessage setAttributes:nameAttribute range:nameRange];
    [attributedMessage setAttributes:messageAttribute range:messageRange];
    [attributedMessage endEditing];
    
    return attributedMessage;
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    CGFloat messageWidth;
    CGFloat filenameWidth;
    CGRect messageRect;
    CGRect filenameRect;
    NSAttributedString *attributedMessage = [self buildMessage];
    
    messageWidth = totalWidth - (kFileLinkLeftMargin + kFileLinkRightMargin);
    messageRect = [attributedMessage boundingRectWithSize:CGSizeMake(messageWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    NSMutableDictionary *filenameAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kFileLinkFileNameFontSize], NSFontAttributeName, UIColorFromRGB(0x595959), NSForegroundColorAttributeName,nil];
    filenameWidth = totalWidth - (kFileLinkLeftMargin + kFileLinkRightMargin + kFileLinkLeftBarWidth);
    filenameRect = [self.filenameLabel.text boundingRectWithSize:CGSizeMake(filenameWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:filenameAttribute context:nil];
    
    return messageRect.size.height + filenameRect.size.height + kFileLinkImageHeight + kFileLinkMarginBetweenFilenameAndImage + kFileLinkTopMargin + kFileLinkBottomMargin + kFileLinkLMarginBetweenMessageAndImageInfo;
}

@end
