//
//  SBDScheduledUserMessage.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 10/26/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"
#import "SBDSender.h"
#import "SBDTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a scheduled user message.
 @since 3.0.119
 */
@interface SBDScheduledUserMessage : NSObject

/**
 The scheduled message ID.
 */
@property (atomic, readonly) long long scheduledId;

/**
 The scheduled message date time. (format: "YYYY-MM-DD HH:mm")
 */
@property (strong, nonnull, readonly) NSString *scheduledDateTimeString;

/**
 The scheduled message timezone. (e.g. UTC, America/Los_Angeles, etc)
 */
@property (strong, nonnull, readonly) NSString *scheduledTimezone;

/**
 The scheduled message status.
 */
@property (atomic, readonly) SBDScheduledUserMessageStatus status;

/**
 Error code. If there isn't error, it's zero.
 */
@property (atomic, readonly) NSInteger errorCode;

/**
 Error message.
 */
@property (strong, nonnull, readonly) NSString *errorMessage;

/**
 The push notification delivery option that determines how to deliver the push notification when sending a user or a file message. The default value is `SBDPushNotificationDeliveryOptionDefault`.
 */
@property (atomic, readonly) SBDPushNotificationDeliveryOption pushOption;

/**
 Message created time in millisecond(UTC).
 */
@property (atomic, readonly) long long createdAt;

/**
 Message updated time in millisecond(UTC).
 */
@property (atomic, readonly) long long updatedAt;

/**
 Target type of mention.
 */
@property (atomic, readonly) SBDMentionType mentionType;

/**
 The list of users who will be mentioned together with the message.
 */
@property (strong, nonnull, readonly) NSArray<SBDUser *> *mentionedUsers;

/**
 Channel URL which will have this message.
 */
@property (strong, nonnull, readonly) NSString *channelUrl;

/**
 Sender of the <span>message</span>. This is represented by `SBDSender` class.
 */
@property (strong, nullable, readonly) SBDSender *sender;

/**
 <span>Message</span> text.
 */
@property (strong, nonnull, readonly) NSString *message;

/**
 The custom data for message.
 */
@property (strong, nonnull, readonly) NSString *data;

/**
 Custom message type.
 */
@property (strong, nonnull, readonly) NSString *customType;

/**
 The target languages that the message will be translated into.
 */
@property (strong, nonnull, readonly) NSArray<NSString *> *targetLanguages;

/**
 Meta array.
 */
@property (nonatomic, nonnull, readonly, getter=getAllMetaArray) NSDictionary<NSString *, NSArray<NSString *> *> *metaArray;

/**
 Checks the channel type is open channel or not.
 
 @return Returns YES, when this is open channel.
 */
- (BOOL)isOpenChannel;

/**
 Checks the channel type is group channel or not.
 
 @return Returns YES, when this is group channel.
 */
- (BOOL)isGroupChannel;

/**
 Returns meta array for the keys.
 
 @param keys Keys of the meta array.
 @return Meta array of the keys.
 */
- (nonnull NSDictionary<NSString *, NSArray<NSString *> *> *)getMetaArrayWithKeys:(NSArray<NSString *> * _Nonnull)keys;

@end

NS_ASSUME_NONNULL_END
