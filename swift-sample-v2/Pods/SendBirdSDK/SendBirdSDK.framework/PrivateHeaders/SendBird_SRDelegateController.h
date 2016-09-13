//
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import <Foundation/Foundation.h>

#import "SendBird_SRWebSocket.h"

NS_ASSUME_NONNULL_BEGIN

struct SendBird_SRDelegateAvailableMethods {
    BOOL didReceiveMessage : 1;
    BOOL didReceiveMessageWithString : 1;
    BOOL didReceiveMessageWithData : 1;
    BOOL didOpen : 1;
    BOOL didFailWithError : 1;
    BOOL didCloseWithCode : 1;
    BOOL didReceivePing : 1;
    BOOL didReceivePong : 1;
    BOOL shouldConvertTextFrameToString : 1;
};
typedef struct SendBird_SRDelegateAvailableMethods SendBird_SRDelegateAvailableMethods;

typedef void(^SendBird_SRDelegateBlock)(id<SendBird_SRWebSocketDelegate> _Nullable delegate, SendBird_SRDelegateAvailableMethods availableMethods);

@interface SendBird_SRDelegateController : NSObject

@property (nonatomic, weak) id<SendBird_SRWebSocketDelegate> delegate;
@property (atomic, readonly) SendBird_SRDelegateAvailableMethods availableDelegateMethods;

@property (nullable, nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nullable, nonatomic, strong) NSOperationQueue *operationQueue;

///--------------------------------------
#pragma mark - Perform
///--------------------------------------

- (void)performDelegateBlock:(SendBird_SRDelegateBlock)block;
- (void)performDelegateQueueBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
