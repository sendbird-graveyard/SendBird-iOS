//
//  FileMessageTableViewCell.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import "FileMessageTableViewCell.h"

#define kFileMessageTopMargin 6.0
#define kFileMessageBottomMargin 6.0
#define kFileMessageLeftMargin 16.0
#define kFileMessageRightMargin 16.0
#define kFileMessageMarginBetweenNameAndMessage 8
#define kFileMessageNameWidth 80.0
#define kFileMessageNameFontSize 14.0
#define kFileMessageFileNameFontSize 11.0
#define kFileMessageFileSizeFontSize 11.0
#define kFileMessageMessageFontSize 14.0
#define kFileMessageImageWidth 31.5
#define kFileMessageImageHeight 39.0

@implementation FileMessageTableViewCell

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
    
    self.nicknameLabel = [[UILabel alloc] init];
    [self.nicknameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nicknameLabel setFont:[UIFont boldSystemFontOfSize:kFileMessageNameFontSize]];
    [self.nicknameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.nicknameLabel setNumberOfLines:0];
    
    self.fileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_icon_file"]];
    [self.fileImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.filenameLabel = [[UILabel alloc] init];
    [self.filenameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.filenameLabel setFont:[UIFont boldSystemFontOfSize:kFileMessageFileNameFontSize]];
    [self.filenameLabel setTextColor:UIColorFromRGB(0x824096)];
    
    self.filesizeLabel = [[UILabel alloc] init];
    [self.filesizeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.filesizeLabel setFont:[UIFont systemFontOfSize:kFileMessageFileSizeFontSize]];
    [self.filesizeLabel setTextColor:UIColorFromRGB(0x824096)];
    
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.fileImageView];
    [self.contentView addSubview:self.filenameLabel];
    [self.contentView addSubview:self.filesizeLabel];
    
    // Nickname Label
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kFileMessageTopMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileMessageNameWidth]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nicknameLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:kFileMessageLeftMargin]];
    
    // File Icon
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kFileMessageTopMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.nicknameLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kFileMessageMarginBetweenNameAndMessage]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileMessageImageWidth]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileMessageImageHeight]];
    
    // File Name
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:kFileMessageTopMargin]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kFileMessageMarginBetweenNameAndMessage]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:-kFileMessageRightMargin]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileMessageFileNameFontSize + 2]];
    
    // File Size
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filenameLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filesizeLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filesizeLabel
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.fileImageView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:kFileMessageMarginBetweenNameAndMessage]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filesizeLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filesizeLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1 constant:kFileMessageFileNameFontSize + 2]];
    
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
    CGFloat fileSize = [[model fileInfo] size];
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    NSAttributedString *nickname = [[NSAttributedString alloc] initWithString:[[model sender] name] attributes:underlineAttribute];
    [self.nicknameLabel setAttributedText:nickname];
    [self.filenameLabel setText:[[model fileInfo] name]];
    [self.filesizeLabel setText:[NSString stringWithFormat:@"%.2fMB", (fileSize / 1024.0 / 1024.0)]];
}

- (CGFloat)getHeightOfViewCell:(CGFloat)totalWidth
{
    CGRect nameRect;
    
    NSDictionary *nameAttribute = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:kFileMessageNameFontSize], NSFontAttributeName, nil];
    
    nameRect = [self.nicknameLabel.text boundingRectWithSize:CGSizeMake(kFileMessageNameWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:nameAttribute context:nil];
    
    return MAX(kFileMessageImageHeight, nameRect.size.height) + kFileMessageTopMargin + kFileMessageBottomMargin;
}

@end
