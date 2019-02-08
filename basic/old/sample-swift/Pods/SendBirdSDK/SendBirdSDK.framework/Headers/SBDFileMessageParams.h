//
//  SBDFileMessageParams.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 3. 5..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import "SBDBaseMessageParams.h"

@class SBDThumbnailSize;

/**
 *  The `SBDFileMessageParams` class is used to send a file message in `SBDBaseChannel`. This is a child class of `SBDBaseMessageParams`.
 */
@interface SBDFileMessageParams : SBDBaseMessageParams

/**
 *  Binary file data.
 *  `file` and `fileUrl` cannot be set together.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSData *file;

/**
 *  File URL.
 *  `file` and `fileUrl` cannot be set together.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSString *fileUrl;

/**
 *  Thumbnail sizes. This parameter is the array of `SBDThumbnailSize` instance and works for image file only.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSArray <SBDThumbnailSize *> *thumbnailSizes;

/**
 *  File name.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSString *fileName;

/**
 *  File MIME type.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSString *mimeType;

/**
 *  File size.
 *
 *  @since 3.0.90
 */
@property (nonatomic) NSUInteger fileSize;

/**
 *  Don't use this initializer.
 *  Initializes an instance of a file message params.
 *
 *  @see -initWithFile: or initWithFileUrl:
 *  @return nil as this method is unavailable.
 *  @since 3.0.90
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 *  Initializes an instance of a file message params with binary file.
 *
 *  @param file A Biniary file to be sent.
 *  @return An initialized file message params, used to send file message.
 *  @since 3.0.90
 */
- (nullable instancetype)initWithFile:(nonnull NSData *)file;

/**
 *  Initializes an instance of a file message params with file url.
 *
 *  @param fileUrl  The file url to be sent.
 *  @return An initialized file message params, used to send file message.
 *  @since 3.0.90
 */
- (nullable instancetype)initWithFileUrl:(nonnull NSString *)fileUrl;

@end
