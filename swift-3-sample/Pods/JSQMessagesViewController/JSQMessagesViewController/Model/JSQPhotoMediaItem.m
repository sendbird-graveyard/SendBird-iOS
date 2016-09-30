//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQPhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"


@interface JSQPhotoMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;

@end


@implementation JSQPhotoMediaItem

#pragma mark - Initialization

- (instancetype)initWithImageURL:(NSString *)imageURL
{
    self = [super init];
    if (self) {
        _imageURL = [imageURL copy];
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
}

#pragma mark - Setters

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = [imageURL copy];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
//    if (self.imageURL == nil) {
//        return nil;
//    }
//    
//    if (self.cachedImageView == nil) {
//        CGSize size = [self mediaViewDisplaySize];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
//        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        imageView.clipsToBounds = YES;
//        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
//        self.cachedImageView = imageView;
//    }
//    
//    return self.cachedImageView;
    
    CGSize size = [self mediaViewDisplaySize];
    NSLog(@"[JSQPhotoMediaItem:83] Size: %f, %f", size.width, size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    NSLog(@"[JSQPhotoMediaItem:88] imageView Size: %f, %f", imageView.frame.size.width, imageView.frame.size.height);
    self.cachedImageView = imageView;
    
    return self.cachedImageView;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.imageURL, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageURL))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.imageURL forKey:NSStringFromSelector(@selector(imageURL))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQPhotoMediaItem *copy = [[JSQPhotoMediaItem allocWithZone:zone] initWithImageURL:self.imageURL];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
