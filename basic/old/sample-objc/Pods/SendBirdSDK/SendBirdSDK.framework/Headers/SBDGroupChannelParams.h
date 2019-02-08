//
//  SBDGroupChannelParams.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 1. 29..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBDUser;

/**
 *  The `SBDGroupChannelParams` class contain parameters for `group channel`. When you want to create a group channel or update a group channel, use this class. Add what you want to create with, add which properties you want to update, and pass this class to `SBDGroupChannel`. You can use this class with apis that are `[SBDGroupChannel createChannel:completionHandler:]` or `[SBDGroupChannel updateChannel:completionHandler:]`.
 *
 *  *
 *
 *  For more information, see [Group Channel](https://docs.sendbird.com/ios#group_channel).
 *
 */

@interface SBDGroupChannelParams : NSObject

/**
 *  Represents the channel is to be updated.
 *  Use in creation only.
 */
@property (nonatomic, copy, nullable) NSString *channelUrl;

/**
 *  Represents the channel is super channel or not.
 *  NO by default.
 */
@property (nonatomic, setter=setSuper:) BOOL isSuper;

/**
 *  Represents the channel is public channel or not.
 *  NO by default, a.k.a. private.
 */
@property (nonatomic, setter=setPublic:) BOOL isPublic;

/**
 *  Represents the channel is distinct or not.
 *  If YES, the channel which has the same users is returned.
 *  NO by default.
 */
@property (nonatomic, setter=setDistinct:) BOOL isDistinct;

/**
 *  Represents the channel is ephemeral or not.
 *  The default value is NO
 *
 *  @since 3.0.90
 */
@property (nonatomic, setter=setEphemeral:) BOOL isEphemeral;

/**
 *  Represents the custom type of group channel.
 */
@property (nonatomic, copy, nullable) NSString *customType;

/**
 *  Represents the custom data of group channel.
 */
@property (nonatomic, copy, nullable) NSString *data;

/**
 *  Represnets the cover image url of group channel.
 */
@property (nonatomic, copy, nullable) NSString *coverUrl;

/**
 *  Represents the cover image data of group channel.
 */
@property (nonatomic, copy, nullable) NSData *coverImage;

/**
 *  Represents the name of group channel.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 *  Represents the operators's user id.
 *  
 *  @since 3.0.89
 */
@property (nonatomic, copy, nullable) NSArray <NSString *> *operatorUserIds;

/**
 *  Add user with SBDUser class to be member of the group channel.
 *
 *  @param user     The user to be member of a group channel.
 */
- (void)addUser:(nonnull SBDUser *)user;

/**
 *  Add user with user id to be member of the group channel.
 *
 *  @param userId   The user id to be member of a group channel.
 */
- (void)addUserId:(nonnull NSString *)userId;

/**
 *  Add users with SBDUser class array to be member of the group channel.
 *
 *  @param users    The users to be member of a group channel.
 */
- (void)addUsers:(nonnull NSArray <SBDUser *> *)users;

/**
 *  Add users with user ids to be member of the group channel.
 *
 *  @param userIds  The user ids to be member of a group channel.
 */
- (void)addUserIds:(nonnull NSArray <NSString *> *)userIds;

/**
 *  Get users that are contained params class.
 *
 *  @return userIds  The user ids to be member of a group channel.
 */
- (nullable NSArray <NSString *> *)userIds;

/**
 *  Set operators with list of user instance.
 *
 *  @param operators The list of operators.
 *  @see operatorUserIds
 *  @since 3.0.89
 */
- (void)setOperators:(nonnull NSArray <SBDUser *> *)operators;

@end
