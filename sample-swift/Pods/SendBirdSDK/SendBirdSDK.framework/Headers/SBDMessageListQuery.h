//
//  SBDMessageListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 7/13/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDBaseMessage.h"
#import "SBDError.h"
#import "SBDBaseChannel.h"

/**
 *  The `SBDMessageListQuery` class is a query class for getting messages from the given channel. The instance of this class is created by [`createMessageListQuery`](../Classes/SBDBaseChannel.html#//api/name/createMessageListQuery) in `SBDBaseChannel` class.
 *
 *  @deprecated in 3.0.28.
 */
__attribute__ ((deprecated))
@interface SBDMessageListQuery : NSObject

/**
 *  Internal use only.
 */
- (nullable instancetype)initWithChannel:(SBDBaseChannel * _Nonnull)channel;

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 *
 *  @deprecated in 3.0.28.
 */
- (BOOL)isLoading DEPRECATED_ATTRIBUTE;

/**
 *  Loads the next messages from the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in 3.0.28.
 */
- (void)loadNextMessagesFromTimestamp:(long long)timestamp limit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Loads the previous messages from the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in 3.0.28.
 */
- (void)loadPreviousMessagesFromTimestamp:(long long)timestamp limit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Loads the previous and next message from the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param prevLimit         The previous limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param nextLimit         The next limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in 3.0.28.
 */
- (void)loadMessagesFromTimestamp:(long long)timestamp prevLimit:(NSInteger)prevLimit nextLimit:(NSInteger)nextLimit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Loads the messages in the time range.
 *
 *  @param startTimestamp    The start timestamp for the range.
 *  @param endTimestamp      The end timestamp for the range.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
//- (void)loadMessagesWithStartTimestamp:(long long)startTimestamp endTimestamp:(long long)endTimestamp completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

@end
