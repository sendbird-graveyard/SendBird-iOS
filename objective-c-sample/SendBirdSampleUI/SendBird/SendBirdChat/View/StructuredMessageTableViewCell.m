//
//  StructuredMessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 10. 14..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import "StructuredMessageTableViewCell.h"

@implementation StructuredMessageTableViewCell

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
    
    self.cellView = [[UIView alloc] init];
    [self.cellView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cellView setBackgroundColor:[UIColor whiteColor]];
    [self.cellView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.titleLabel setTextColor:UIColorFromRGB(0x343434)];
    [self.titleLabel setNumberOfLines:2];
    
    self.thumbImageView = [[UIImageView alloc] init];
    [self.thumbImageView setBackgroundColor:[UIColor whiteColor]];
    [self.thumbImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.thumbImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.thumbImageView setClipsToBounds:YES];
    
    self.descLabel = [[UILabel alloc] init];
    [self.descLabel setBackgroundColor:[UIColor clearColor]];
    [self.descLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.descLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.descLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.descLabel setTextColor:UIColorFromRGB(0xa6a6a6)];
    [self.descLabel setNumberOfLines:2];
    
    self.dividerView = [[UIView alloc] init];
    [self.dividerView setBackgroundColor:UIColorFromRGB(0xe5e5e5)];
    [self.dividerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.structuredIconImageView = [[UIImageView alloc] init];
//    [self.structuredIconImageView setBackgroundColor:[UIColor redColor]];
    [self.structuredIconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.structuredNameLabel = [[UILabel alloc] init];
//    [self.structuredNameLabel setBackgroundColor:[UIColor blueColor]];
    [self.structuredNameLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.structuredNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.structuredNameLabel setTextColor:UIColorFromRGB(0x343434)];
    [self.structuredNameLabel setText:@"IMDb"];
    
    [self addSubview:self.cellView];
    [self.cellView addSubview:self.thumbImageView];
    [self.cellView addSubview:self.titleLabel];
    [self.cellView addSubview:self.descLabel];
    [self.cellView addSubview:self.dividerView];
    [self.cellView addSubview:self.structuredIconImageView];
    [self.cellView addSubview:self.structuredNameLabel];
    
    // Content View
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cellView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:2.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cellView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:-2.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cellView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:18]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cellView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:-18]];
    
    // Message Label
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cellView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cellView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:10]];
    
    // Thumbnail ImageView
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cellView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:8]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.cellView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:-10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:74]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:74]];
    
    // Description Label
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.titleLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.descLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cellView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1 constant:10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbImageView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.descLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1 constant:8]];

    // Divider
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.thumbImageView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cellView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1 constant:0]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cellView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1 constant:0]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.dividerView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1 constant:0.5]];
    
    // Structured Icon
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.dividerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:5]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cellView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1 constant:10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1 constant:20]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1 constant:20]];
    
    // Structured Name
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredNameLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.dividerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:5]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredIconImageView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.structuredNameLabel
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1 constant:-5]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredNameLabel
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cellView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1 constant:-10]];
    [self.cellView addConstraint:[NSLayoutConstraint constraintWithItem:self.structuredNameLabel
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.cellView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1 constant:-5]];
}

- (void) setModel:(SendBirdStructuredMessage *)model
{
    self.structuredMessage = model;
    [self.titleLabel setText:[model structuredMessageTitle]];
    [self.descLabel setText:[model structuredMessageDesc]];
    [self.structuredNameLabel setText:[model structuredMessageName]];
    
    if ([model structuredMessageThumbUrl] != nil && [[model structuredMessageThumbUrl] length] > 0) {
        [SendBirdUtils loadImage:[model structuredMessageThumbUrl] imageView:self.thumbImageView width:74 height:74];
    }
    else {
        [self.thumbImageView setImage:nil];
    }
         
    if ([model structuredMessageIconUrl] != nil && [[model structuredMessageIconUrl] length] > 0) {
        [SendBirdUtils loadImage:[self.structuredMessage structuredMessageIconUrl] imageView:self.structuredIconImageView width:20 height:20];
    }
    else {
     [self.structuredIconImageView setImage:nil];
    }
}

//- (NSAttributedString *)buildMessage
//{
//    NSMutableDictionary *nameAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:kFileLinkMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x824096), NSForegroundColorAttributeName, nil];
//    NSMutableDictionary *messageAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kFileLinkMessageFontSize], NSFontAttributeName, UIColorFromRGB(0x595959), NSForegroundColorAttributeName,nil];
//    NSString *fileLinkUrl = [[self.fileLink fileInfo] url];
//    if ([[[self.fileLink fileInfo] type] hasPrefix:@"image"]) {
//        fileLinkUrl = @"";
//    }
//    NSString *message = [[NSString stringWithFormat:@"%@: %@", [[self.fileLink sender] name], fileLinkUrl] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
//    //    NSString *message = [[NSString stringWithFormat:@"%@: %@", [[self.fileLink sender] name], [[self.fileLink fileInfo] url]] stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
//    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"\u00A0"];
//    message = [message stringByReplacingOccurrencesOfString:@"-" withString:@"\u2011"];
//    message = [message stringByReplacingOccurrencesOfString:@"/" withString:@"\u2215"];
//    
//    int badge = 0;
//    if ([self.fileLink isOpMessage]) {
//        message = [NSString stringWithFormat:@"\u00A0\u00A0%@", message];
//        badge = 2;
//    }
//    
//    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:message];
//    NSRange nameRange = NSMakeRange(badge, [[[self.fileLink sender] name] length]);
//    //    NSRange messageRange = NSMakeRange([[[self.fileLink sender] name] length] + badge, [[[self.fileLink fileInfo] url] length] + 2);
//    NSRange messageRange = NSMakeRange([[[self.fileLink sender] name] length] + badge, [fileLinkUrl length] + 2);
//    
//    if ([self.fileLink isOpMessage]) {
//        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
//        textAttachment.image = [UIImage imageNamed:@"_icon_admin"];
//        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
//        [attributedMessage replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
//    }
//    
//    [attributedMessage beginEditing];
//    [attributedMessage setAttributes:nameAttribute range:nameRange];
//    [attributedMessage setAttributes:messageAttribute range:messageRange];
//    [attributedMessage endEditing];
//    
//    return attributedMessage;
//}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
//    CGFloat messageWidth;
//    CGFloat filenameWidth;
//    CGRect messageRect;
//    CGRect filenameRect;
//    NSAttributedString *attributedMessage = [self buildMessage];
//    
//    messageWidth = totalWidth - (kFileLinkLeftMargin + kFileLinkRightMargin);
//    messageRect = [attributedMessage boundingRectWithSize:CGSizeMake(messageWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
//    
//    NSMutableDictionary *filenameAttribute = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kFileLinkFileNameFontSize], NSFontAttributeName, UIColorFromRGB(0x595959), NSForegroundColorAttributeName,nil];
//    filenameWidth = totalWidth - (kFileLinkLeftMargin + kFileLinkRightMargin + kFileLinkLeftBarWidth);
//    filenameRect = [self.filenameLabel.text boundingRectWithSize:CGSizeMake(filenameWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:filenameAttribute context:nil];
//    
//    return messageRect.size.height + filenameRect.size.height + kFileLinkImageHeight + kFileLinkMarginBetweenFilenameAndImage + kFileLinkTopMargin + kFileLinkBottomMargin + kFileLinkLMarginBetweenMessageAndImageInfo;
    
    return 129.0;
}

@end
