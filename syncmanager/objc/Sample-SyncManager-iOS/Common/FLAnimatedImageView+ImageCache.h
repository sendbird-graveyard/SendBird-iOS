//
//  FLAnimatedImageView+ImageCache.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Gyeong on 3/16/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>

@interface FLAnimatedImageView (ImageCache)

- (void)setAnimatedImageWithURL:(NSURL * _Nonnull)url success:(nullable void (^)(FLAnimatedImage * _Nullable image))success failure:(nullable void (^)(NSError * _Nullable error))failure;
+ (nullable NSData *)cachedImageForURL:(NSURL * _Nonnull)url;

@end
