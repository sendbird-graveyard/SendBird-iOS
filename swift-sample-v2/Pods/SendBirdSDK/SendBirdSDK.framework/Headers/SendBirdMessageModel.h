//
//  SendBirdMessageModel.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 24..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Is a super class of [`SendBirdMessage`](./SendBirdMessage.html), [`SendBirdBroadcastMessage`](./SendBirdBroadcastMessage.html), [`SendBirdFileLink`](./SendBirdFileLink.html), [`SendBirdChannel`](./SendBirdChannel.html)
 */
@interface SendBirdMessageModel : NSObject

- (id) init;

/**
 *  Set the message status to be a new message
 *
 *  @param tf YES to set new, otherwise NO
 */
- (void) setPresent:(BOOL)tf;

/**
 *  Check if the message is an old one
 *
 *  @return Returns YES if old, otherwise returns NO
 */
- (BOOL) isPast;

/**
 *  Check if the message has newly been received
 *
 *  @return Returns YES if new, otherwise returns NO
 */
- (BOOL) isPresent;

/**
 *  Check if the message has a Message ID
 *
 *  @return Returns YES if Message ID is found, otherwise returns NO
 */
- (BOOL) hasMessageId;

/**
 *  Get Message ID
 *
 *  @return Message ID
 */
- (long long) getMessageId;

/**
 *  Get Message ID from message sent as NSDictionary class
 *
 *  @param dic Received message
 *
 *  @return Message ID
 */
- (long long) parseMessageId:(NSDictionary *)dic;

/**
 *  Get the UTC timestamp of the message
 *
 *  @return UTC Timestamp
 */
- (long long) getMessageTimestamp;

/**
 *  Get the UTC timestamp of the message sent as NSDictionary class
 *
 *  @param dic Received message
 *
 *  @return UTC Timestamp
 */
- (long long) parseMessageTimestamp:(NSDictionary *)dic;

- (long long) parseChannelId:(NSDictionary *)dic;

- (long long) getChannelId;

/**
 *  Parse a message received as JSON String
 *
 *  @param data    Messaged in the form of JSON String
 *  @param present Set to YES if new, otherwise set to NO
 *
 *  @return `SendBirdMessageModel` object made from message in JSON String format
 */
+ (SendBirdMessageModel *) parseData:(NSString *)data isPresent:(BOOL)present;

@end
