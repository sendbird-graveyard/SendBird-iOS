//
//  JSQFileMediaItem.h
//  JSQMessages
//
//  Created by Jed Kyung on 7/29/16.
//  Copyright © 2016 Hexed Bits. All rights reserved.
//

#import "JSQMediaItem.h"

@interface JSQFileMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

/**
 *  The URL that identifies a file resource.
 */
@property (nonatomic, strong) NSURL *fileURL;

/**
 *  Initializes and returns a file item having the given fileURL.
 *
 *  @param fileURL The URL that identifies the file resource.
 *
 *  @return An initialized `JSQFileMediaItem` if successful, `nil` otherwise.
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end
