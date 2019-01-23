//
//  SBDConstants.h
//  SendBirdSDK
//
//  Created by sendbird-young on 12/10/2018.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#ifndef SBDConstants_h
#define SBDConstants_h

#import <Foundation/Foundation.h>
#import "SBDError.h"

@class SBDGroupChannel, SBDOpenChannel;
@class SBDBaseMessage, SBDFileMessage;
@class SBDError;

typedef void (^SBDOpenChannelHandler)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error);
typedef void (^SBDFileMessageHandler)(SBDFileMessage * _Nullable message, SBDError * _Nullable error);
typedef void (^SBDBinaryProgressHandler)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^SBDMessageChangeLogsHandler)(NSArray<SBDBaseMessage *> * _Nullable updatedMessages,
                                            NSArray<NSNumber *> * _Nullable deletedMessageIds,
                                            BOOL hasMore,
                                            NSString * _Nullable token,
                                            SBDError * _Nullable error);
typedef void(^SBDChannelChangeLogsHandler)(NSArray <SBDGroupChannel *> * _Nullable updatedChannels,
                                           NSArray <NSString *> * _Nullable deletedChannelUrls,
                                           BOOL hasMore,
                                           NSString * _Nullable token,
                                           SBDError * _Nullable error);
typedef void(^SBDSnoozePeriodHandler)(BOOL enabled,
                                      long long startTimestamp,
                                      long long endTimestamp,
                                      SBDError * _Nullable error);
typedef void(^SBDPushTriggerOptionHandler)(SBDPushTriggerOption pushTriggerOption,
                                           SBDError * _Nullable error);
typedef void(^SBDGroupChannelPushTriggerOptionHandler)(SBDGroupChannelPushTriggerOption pushTriggerOption,
                                                       SBDError * _Nullable error);
typedef void(^SBDErrorHandler)(SBDError * _Nullable error);

#endif /* SBDConstants_h */
