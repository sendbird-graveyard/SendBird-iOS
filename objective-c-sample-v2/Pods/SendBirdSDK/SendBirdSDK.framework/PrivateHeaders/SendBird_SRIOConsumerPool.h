//
// Copyright 2012 Square Inc.
// Portions Copyright (c) 2016-present, Facebook, Inc.
//
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import <Foundation/Foundation.h>

#import "SendBird_SRIOConsumer.h" // TODO: (nlutsenko) Convert to @class and constants file for block types

// This class is not thread-safe, and is expected to always be run on the same queue.
@interface SendBird_SRIOConsumerPool : NSObject

- (instancetype)initWithBufferCapacity:(NSUInteger)poolSize;

- (SendBird_SRIOConsumer *)consumerWithScanner:(SendBird_stream_scanner)scanner
                              handler:(SendBird_data_callback)handler
                          bytesNeeded:(size_t)bytesNeeded
                   readToCurrentFrame:(BOOL)readToCurrentFrame
                          unmaskBytes:(BOOL)unmaskBytes;
- (void)returnConsumer:(SendBird_SRIOConsumer *)consumer;

@end
