//
//  SBDMessageListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 6/2/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDMain.h"
#import "SBDBaseChannel.h"

/**
 *  An object which retrieves messages from the given channel. The instance of this class is created by [`createPreviousMessageListQuery`](../Classes/SBDBaseChannel.html#//api/name/createPreviousMessageListQuery) in `SBDBaseChannel` class.
 */
@interface SBDPreviousMessageListQuery : NSObject

/**
 *  Initializes object.
 *
 *  @param channel SBDBaseChannel object.
 *
 *  @return SBDPreviousMessageListQuery object.
 */
- (instancetype _Nullable)initWithChannel:(SBDBaseChannel * _Nonnull)channel;

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;

/**
 *  Loads previous message with limit.
 *
 *  @param limit             The number of messages per page.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)loadPreviousMessagesWithLimit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

@end
