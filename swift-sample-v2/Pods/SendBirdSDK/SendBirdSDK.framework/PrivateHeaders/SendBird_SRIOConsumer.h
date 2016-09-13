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

@class SendBird_SRWebSocket; // TODO: (nlutsenko) Remove dependency on SendBird_SRWebSocket here.

// Returns number of bytes consumed. Returning 0 means you didn't match.
// Sends bytes to callback handler;
typedef size_t (^SendBird_stream_scanner)(NSData *collected_data);
typedef void (^SendBird_data_callback)(SendBird_SRWebSocket *webSocket,  NSData *data);

@interface SendBird_SRIOConsumer : NSObject {
    SendBird_stream_scanner _scanner;
    SendBird_data_callback _handler;
    size_t _bytesNeeded;
    BOOL _readToCurrentFrame;
    BOOL _unmaskBytes;
}
@property (nonatomic, copy, readonly) SendBird_stream_scanner consumer;
@property (nonatomic, copy, readonly) SendBird_data_callback handler;
@property (nonatomic, assign) size_t bytesNeeded;
@property (nonatomic, assign, readonly) BOOL readToCurrentFrame;
@property (nonatomic, assign, readonly) BOOL unmaskBytes;

- (void)resetWithScanner:(SendBird_stream_scanner)scanner
                 handler:(SendBird_data_callback)handler
             bytesNeeded:(size_t)bytesNeeded
      readToCurrentFrame:(BOOL)readToCurrentFrame
             unmaskBytes:(BOOL)unmaskBytes;

@end
