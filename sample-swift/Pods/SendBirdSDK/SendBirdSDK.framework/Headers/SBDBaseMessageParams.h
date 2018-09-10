//
//  SBDBaseMessageParams.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 3. 5..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDTypes.h"

@class SBDUser;

/**
 *  The `SBDBaseMessageParams` class represents the base class which has parameters to create a channel or update a channel. The `SBDUserMessageParams`, the `SBDFileMessageParams` are derived from this class.
 */
@interface SBDBaseMessageParams : NSObject

/**
 *  Message data. The default value is nil.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSString *data;

/**
 *  Customize message's type to filter. The default value is nil.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSString *customType;

/**
 The push notification delivery option that determines how to deliver the push notification when sending a user or a file message. The default value is `SBDPushNotificationDeliveryOptionDefault`.
 */
@property (atomic) SBDPushNotificationDeliveryOption pushNotificationDeliveryOption;

/**
 *
 *  @since 3.0.103
 */
@property (atomic) SBDMentionType mentionType;

/**
 *  Can mention to specific users.
 *  If sends a message with this field, the message will be arrived to mentioned users.
 *  The default value is nil.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSArray <NSString *> *mentionedUserIds;

/**
 *  Can set the `mentionedUserIds` by this method either.
 *
 *  @param mentionedUsers The list of users will be receive mention.
 *  @since 3.0.90
 */
- (void)setMentionedUsers:(nonnull NSArray <SBDUser *> *)mentionedUsers;

@end
