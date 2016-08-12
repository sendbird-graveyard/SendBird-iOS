//
//  SendBirdSystemMessage.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 2. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdMessageModel.h"

#define kSendBirdCategoryNone 0
#define kSendBirdCategoryChannelJoin 10100
#define kSendBirdCategoryChannelLeave 10101
#define kSendBirdCategoryChannelInvite 10102
#define kSendBirdCategoryTooManyMessages 10200
#define kSendBirdCategoryMessagingUserBlocked 10300
#define kSendBirdCategoryMessagingUserDeactivated 10400

/**
 *  Class used for system messages. The object is returned when systemMessageReceived callback is invoked by [`setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:`](./SendBird.html#//api/name/setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:) of [`SendBird`](./SendBird.html)
 */
@interface SendBirdSystemMessage : SendBirdMessageModel

/**
 *  Message body
 */
@property (retain) NSString *message;

@property (retain) NSDictionary *jsonObj;

/**
 *  Message type
 *
 *  - Joined the channel  - 10100
 *  - Left the channel - 10101
 *  - Invited to the channel - 10102
 *  - Muted - 10500
 */
@property long long category;

- (id) initWithDic:(NSDictionary *)dic inPresent:(BOOL)present;
- (NSString *) toJson;

@end
