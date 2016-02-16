//
//  SendBirdTypeStatus.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdUser.h"

/**
 *  Class used to display typing indicators within Messaging/Group messaging channel. This class is returned when typeStartReceivedBlock or typeEndReceivedBlock callback is invoked by [`setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:`](./SendBird.html#//api/name/setEventHandlerConnectBlock:errorBlock:channelLeftBlock:messageReceivedBlock:systemMessageReceivedBlock:broadcastMessageReceivedBlock:fileReceivedBlock:messagingStartedBlock:messagingUpdatedBlock:messagingEndedBlock:allMessagingEndedBlock:messagingHiddenBlock:allMessagingHiddenBlock:readReceivedBlock:typeStartReceivedBlock:typeEndReceivedBlock:allDataReceivedBlock:messageDeliveryBlock:) of [`SendBird`](./SendBird.html)
 */
@interface SendBirdTypeStatus : NSObject

/**
 *  User information who started typing or ended typing
 */
@property (retain) SendBirdUser *user;

/**
 *  UTC timestamp of typing start/end event
 */
@property long long timestamp;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *)dic;

- (NSString *) toJson;

@end
