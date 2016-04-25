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

#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "JSQMessagesCollectionViewFlowLayout.h"

@implementation JSQMessagesAvatarImage 

#pragma mark - Initialization

+ (instancetype)avatarWithImageURL:(NSString *)imageURL
{
    NSParameterAssert(imageURL != nil);
    UIImage *placeHolderImage = [JSQMessagesAvatarImageFactory circularAvatarPlaceholderImage:@""
                                                                              backgroundColor:[UIColor lightGrayColor]
                                                                                    textColor:[UIColor darkGrayColor]
                                                                                         font:[UIFont systemFontOfSize:13.0f]
                                                                                     diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    return [[JSQMessagesAvatarImage alloc] initWithAvatarImageURL:imageURL
                                              highlightedImageURL:imageURL
                                              placeholderImage:placeHolderImage
                                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

+ (instancetype)avatarImageWithPlaceholder:(UIImage *)placeholderImage
{
    return [[JSQMessagesAvatarImage alloc] initWithAvatarImageURL:nil
                                              highlightedImageURL:nil
                                              placeholderImage:placeholderImage
                                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (instancetype)initWithAvatarImageURL:(NSString *)avatarImageURL
                   highlightedImageURL:(NSString *)highlightedImageURL
                   placeholderImage:(UIImage *)placeholderImage
                   diameter:(NSUInteger)diameter
{
    NSParameterAssert(placeholderImage != nil);
    
    self = [super init];
    if (self) {
        _avatarImageURL = avatarImageURL;
        _avatarHighlightedImageURL = highlightedImageURL;
        _avatarPlaceholderImage = placeholderImage;
        _diameter = diameter;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: avatarImage=%@, avatarHighlightedImage=%@, avatarPlaceholderImage=%@>",
            [self class], self.avatarImageURL, self.avatarHighlightedImageURL, self.avatarPlaceholderImage];
}

- (id)debugQuickLookObject
{
    if (self.avatarImageURL) {
        return nil;
    }
    else {
        return [[UIImageView alloc] initWithImage:self.avatarPlaceholderImage];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithAvatarImageURL:self.avatarImageURL.copy
                                                 highlightedImageURL:self.avatarHighlightedImageURL.copy
                                                 placeholderImage:[UIImage imageWithCGImage:self.avatarPlaceholderImage.CGImage]
                                                diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

@end
