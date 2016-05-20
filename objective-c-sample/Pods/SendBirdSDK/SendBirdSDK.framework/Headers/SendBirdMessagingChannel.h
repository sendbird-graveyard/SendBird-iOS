//
//  SendBirdMessagingChannel.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdChannel.h"
#import "SendBirdMessage.h"

/**
 *  Class used for Messaging/Group messaging channel. This class includes [`SendBirdChannel`](./SendBirdChannel.html) object. This contains information such as: users within the channel, timestamp of each users' most recent read receipts, unread message counts for the current user, last message within the channel, new messages created after the current user joined the channel, channel type (1-on-1 or group), etc.
 */
@interface SendBirdMessagingChannel : NSObject

/**
 *  Messaging channel information
 */
@property (retain) SendBirdChannel *channel;

@property (retain) NSDictionary *jsonObj;

/**
 *  List of members participating in the Messaging/Group messaging channel
 */
@property (retain) NSMutableArray *members;

/**
 *  List of the recent read receipts of members in the Messaging/Group messaging channel
 */
@property (retain) NSMutableDictionary *readStatus;

/**
 *  Unread message count of the current user in the Messaging channel
 */
@property int unreadMessageCount;

/**
 *  Last message within Messaging/Group messaging channel
 */
@property (retain) SendBirdMessageModel *lastMessage;

/**
 *  If this value is 0, then it means no new messages were created within the channel after joining.
 *
 *  @deprecated in 2.2.4 Please use hasNewMessageSinceJoined instead.
 */
@property int messageCountSinceJoined DEPRECATED_ATTRIBUTE;

/**
 *  Check if the channel has a new message since the user joined
 */
@property BOOL hasNewMessageSinceJoined;

/**
 *  Messaging channel type. 1 on 1 = 5, Group messaging = 6
 */
@property int channelType;

- (id) initWithDic:(NSDictionary *) dic;

- (NSString *) toJson;

/**
 *  Get the timestamp of the last read receipt for the target user
 *
 *  @param userId User ID. Same as [`SendBirdUser guestID`](./SendBirdUser.html#//api/name/guestId)
 *
 *  @return UTC timestamp of the last read receipt for that user
 */
- (long long) getLastReadMillis:(NSString *)userId;

- (long long) getId;

/**
 *  Check if the channel is a Group messaging channel
 *
 *  @return Returns YES if the type is a Group messaging channel, otherwise returns NO
 */
- (BOOL) isGroupMessagingChannel;

/**
 *  Check if the channel is a Messaging channel
 *
 *  @return Returns YES if the type is a Messaging channel, otherwise returns NO
 */
- (BOOL) isMessagingChannel;

/**
 *  Retrieve Channel URL
 *
 *  @return Channel URL
 */
- (NSString *) getUrl;

/**
 *  Returns Channel URL without the Namespace. Channel URL is comprised of a unique Namespace along with the channel identifier string. Use this method to retrieve the identifier part of the URL without the Namespace.
 *
 *  @return Channel URL without the Namespace
 */
- (NSString *) getUrlWithoutAppPrefix;

/**
 *  Retrieves Cover image URL
 *
 *  @return Cover image URL
 */
- (NSString *) getCoverUrl;

/**
 *  Get the number of members in the channel
 *
 *  @return Number of members
 */
- (unsigned long) getMemberCount;

/**
 *  Check if there was a last message in the channel
 *
 *  @return Returns YES if there is a last message, otherwise returns NO
 */
- (BOOL) hasLastMessage;

/**
 *  Get the UTC timestamp of the last message in the channel
 *
 *  @return UTC Timestamp of the last mesage
 */
- (long long) getLastMessageTimestamp;

/**
 *  Update the last message in the channel
 *
 *  @param messageJson Message body
 */
- (void) updateLastMessage:(NSString *) messageJson;

/**
 *  Update unread message count
 *
 *  @param count Unread message count
 */
- (void) updateUnreadMessageCount:(int) count;

/**
 *  Retrieve the channel topic
 *
 *  @return Channel Topic
 */
- (NSString *) getName;

/**
 *  Retrieve channel creation timestamp
 *
 *  @return UTC timestamp of the creation time
 */
- (long long) getCreatedAt;

@end
