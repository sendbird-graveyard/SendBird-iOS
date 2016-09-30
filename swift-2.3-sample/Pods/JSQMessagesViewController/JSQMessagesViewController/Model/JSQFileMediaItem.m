//
//  JSQFileMediaItem.m
//  JSQMessages
//
//  Created by Jed Kyung on 7/29/16.
//  Copyright © 2016 Hexed Bits. All rights reserved.
//

#import "JSQFileMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"

@interface JSQFileMediaItem ()

@property (strong, nonatomic) UIImageView *cachedFileIconImageView;

@end

@implementation JSQFileMediaItem

#pragma mark - Initialization

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self) {
        _fileURL = [fileURL copy];
        _cachedFileIconImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedFileIconImageView = nil;
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedFileIconImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedFileIconImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil) {
        return nil;
    }
    
    if (self.cachedFileIconImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImage *fileIcon = [UIImage jsq_defaultFileImage];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:fileIcon];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeCenter;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedFileIconImageView = imageView;
    }
    
    return self.cachedFileIconImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQFileMediaItem *fileItem = (JSQFileMediaItem *)object;
    
    return [self.fileURL isEqual:fileItem.fileURL];
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@ appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQFileMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
