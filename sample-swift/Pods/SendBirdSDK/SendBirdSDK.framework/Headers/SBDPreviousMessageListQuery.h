//
//  SBDMessageListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 6/2/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDBaseChannel.h"

/**
 *  An object which retrieves messages from the given channel. The instance of this class is created by [`createPreviousMessageListQuery`](../Classes/SBDBaseChannel.html#//api/name/createPreviousMessageListQuery) in `SBDBaseChannel` class.
 */
@interface SBDPreviousMessageListQuery : NSObject

/**
 *  Sets the number of messages per page. The default value is 30.
 *  @since 3.0.106
 */
@property (atomic) NSUInteger limit;

/**
 *  Sets the order of messages. If YES, the latest message is the index 0. The default value is NO.
 *  @since 3.0.106
 */
@property (atomic) BOOL reverse;

/**
 *  Sets the message type to filter messages. The default value is `SBDMessageTypeFilterAll`.
 *
 *  @param messageType Message type to filter messages.
 *  @since 3.0.106
 */
- (void)setMessageTypeFilter:(SBDMessageTypeFilter)messageType;

/**
 *  Sets the custom type to filter messages.
 *
 *  @param customType Custom type to filter messages.
 *  @since 3.0.106
 */
- (void)setCustomTypeFilter:(NSString * _Nullable)customType;

/**
 *  Sets the senders' user IDs filter.
 *
 *  @param senderUserIds The senders' user IDs.
 *  @since 3.0.106
 */
- (void)setSenderUserIdsFilter:(NSArray<NSString *> * _Nullable)senderUserIds;

/**
 *  DO NOT USE this initializer. Use `[SBDBaseChannel createPreviousMessageListQuery]` instead.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;

/**
 *  Loads previous messages.
 *
 *  @param limit             The number of messages per page.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)loadPreviousMessagesWithLimit:(NSInteger)limit
                              reverse:(BOOL)reverse
                    completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

/**
 *  Loads previous messages.
 *
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)loadWithCompletionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

@end
