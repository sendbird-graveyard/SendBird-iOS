//
//  SendBirdReadStatus.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdUser.h"

/**
 *  Class used for handling read receipts of a user within Messaging/Group messaging channel. This class is returned when `readReceivedBlock` callback of [`SendBird setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:`](./SendBird.html#//api/name/setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:)is called, and this callback is invoked when another user in the channel calls [`markAsRead`](./SendBird.html#//api/name/markAsRead), [`markAsReadForChannel:`](./SendBird.html#//api/name/markAsReadForChannel:), [`markAllAsRead`](./SendBird.html#//api/name/markAllAsRead).
 */
@interface SendBirdReadStatus : NSObject

/**
 *  User who called [`markAsRead`](./SendBird.html#//api/name/markAsRead), [`markAsReadForChannel:`](./SendBird.html#//api/name/markAsReadForChannel:), [`markAllAsRead`](./SendBird.html#//api/name/markAllAsRead) after joining the channel
 */
@property (retain) SendBirdUser *user;

/**
 *  Timestamp when the user called [`markAsRead`](./SendBird.html#//api/name/markAsRead), [`markAsReadForChannel:`](./SendBird.html#//api/name/markAsReadForChannel:), [`markAllAsRead`](./SendBird.html#//api/name/markAllAsRead)
 */
@property long long timestamp;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *)dic;

/**
 *  Returns a unique identifier [`SendBirdUser`](./SendBirdUser.html)의 [`guestId`](./SendBirdUser.html#//api/name/guestId)
 *
 *  @return [`SendBirdUser guestId`](./SendBirdUser.html#//api/name/guestId)
 */
- (NSString *) getUserId;

- (NSString *) toJson;

@end
