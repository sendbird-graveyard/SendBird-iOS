//
//  SendBirdMessage.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 2. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdSender.h"
#import "SendBirdMessageModel.h"

/**
 *  Class for messaging. Used in callbacks retrieving the messages.
 *
 *  - Returns from `messageReceived` callback in [`setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:`](./SendBird.html#//api/name/setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:) of [`SendBird`](./SendBird.html)
 *  - Returns as a part of `queryResult` from `onResult` in [`nextWithMessageTs:andLimit:resultBlock:endBlock:`](./SendBirdMessageListQuery.html#//api/name/nextWithMessageTs:andLimit:resultBlock:endBlock:), [`prevWithMessageTs:andLimit:resultBlock:endBlock:`](./SendBirdMessageListQuery.html#//api/name/prevWithMessageTs:andLimit:resultBlock:endBlock:), [`loadWithMessageTs:prevLimit:andNextLimit:resultBlock:endBlock:`](./SendBirdMessageListQuery.html#//api/name/loadWithMessageTs:prevLimit:andNextLimit:resultBlock:endBlock:) of [`SendBirdMessageListQuery`](./SendBirdMessageListQuery.html)
 */

@interface SendBirdMessage : SendBirdMessageModel

/**
 *  Message body
 */
@property (retain) NSString *message;

/**
 *  Message sender
 */
@property (retain) SendBirdSender *sender;

@property BOOL isOpMessage;

@property BOOL isGuestMessage;

/**
 *  Additional data sent along with the message
 */
@property (retain) NSString *data;

@property (retain) NSDictionary *jsonObj;

/**
 *  Message ID used for verifying successful delivery
 */
@property (retain) NSString *tempId;

/**
 *  Returns YES if the user is blocked, otherwise returns NO
 */
@property BOOL isBlocked;

/**
 *  Returns YES if the user is muted, otherwise returns NO
 */
@property BOOL isSoftMuted;

- (id) initWithDic:(NSDictionary *)dic;

- (id) initWithDic:(NSDictionary *)dic inPresent:(BOOL)present;

/**
 *  Method used for checking if the senders are the same person
 *
 *  @param msg Message to compare
 *
 *  @return Returns YES if the same, otherwise returns NO
 */
- (BOOL) hasSameSender:(SendBirdMessage *)msg;

/**
 *  Returns the name of the sender
 *
 *  @return User name of the sender
 */
- (NSString *)getSenderName;

- (void) mergeWith:(SendBirdMessage *)merge DEPRECATED_ATTRIBUTE;

- (NSString *) toJson;

@end
