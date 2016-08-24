//
//  SBDOpenChannel.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDBaseChannel.h"
#import "SBDUser.h"
#import "SBDUserListQuery.h"

@class SBDOpenChannel;
@class SBDOpenChannelListQuery;

/**
 * Represents an open channel.
 */
@interface SBDOpenChannel : SBDBaseChannel

/**
 *  The number of participants in this channel.
 */
@property (nonatomic, readonly) NSInteger participantCount;

/**
 *  The operators of this channel.
 */
@property (strong, nonatomic, readonly, nullable) NSMutableArray<SBDUser *> *operators;

/**
 *  Clear cached channels.
 */
+ (void)clearCache;

/**
 *  Remove cached channel.
 *
 *  @param channelUrl The channel URL.
 */
+ (void)removeChannelFromCacheWithChannelUrl:(NSString * _Nonnull)channelUrl;

/**
 *  Initialize instance with dictionary of open channel.
 *
 *  @param dict The dictionary of open channel.
 *
 *  @return The instance of open channel.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Create query instance for open channel list.
 *
 *  @return The query instance for open channel list.
 */
+ (nullable SBDOpenChannelListQuery *)createOpenChannelListQuery;

/**
 *  Create an open channel.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithCompletionHandler:(nonnull void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create an open channel.
 *
 *  @param name              The name of the channel.
 *  @param coverUrl          The cover image URL.
 *  @param data              The data for channel.
 *  @param operatorUsers     The operator users of channel.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data operatorUsers:(NSArray<SBDUser *> * _Nullable)operatorUsers completionHandler:(nonnull void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create an open channel.
 *
 *  @param name              The name of the channel.
 *  @param coverUrl          The cover image URL.
 *  @param data              The data for channel.
 *  @param operatorUserIds   The operator users of channel.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data operatorUserIds:(NSArray<NSString *> * _Nullable)operatorUserIds completionHandler:(nonnull void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Get an open channel instance from channel URL asynchronously.
 *
 *  @param channelUrl        The channel URL.
 *  @param completionHandler The handler block to execute.
 */
+ (void)getChannelWithUrl:(NSString * _Nonnull)channelUrl completionHandler:(nullable void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Enter the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)enterChannelWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Exit the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)exitChannelWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Create a query instance for getting participant list of the channel instance.
 *
 *  @return SBDUserListQuery instance for the participant list of the channel instance.
 */
- (nullable SBDUserListQuery *)createParticipantListQuery;

/**
 *  Create a query instance for getting muted user list of the channel instance.
 *
 *  @return SBDUserListQuery instance for the muted user list.
 */
- (nullable SBDUserListQuery *)createMutedUserListQuery;

/**
 *  Create a query instance for getting banned user list of the channel instance.
 *
 *  @return SBDUserListQuery instance for the banned user list.
 */
- (nullable SBDUserListQuery *)createBannedUserListQuery;

/**
 *  Refresh the channel information.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)refreshWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  The entered channels. SendBird internal use only.
 */
+ (nullable NSMutableDictionary<NSString *, SBDOpenChannel *> *)enteredChannels;

/**
 *  Ban user.
 *
 *  @param user              The user object.
 *  @param seconds           Duration for ban in seconds.
 *  @param completionHandler The handler block to execute.
 */
- (void)banUser:(SBDUser * _Nonnull)user seconds:(int)seconds completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Ban user with user ID.
 *
 *  @param userId            The user ID.
 *  @param seconds           Duration for ban in seconds.
 *  @param completionHandler The handler block to execute.
 */
- (void)banUserWithUserId:(NSString * _Nonnull)userId seconds:(int)seconds completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unban user.
 *
 *  @param user              The user object.
 *  @param completionHandler The handler block to execute.
 */
- (void)unbanUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unban user with user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
- (void)unbanUserWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Mute user.
 *
 *  @param user              The user object.
 *  @param completionHandler The handler block to execute.
 */
- (void)muteUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Mute user with user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
- (void)muteUserWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unmute user.
 *
 *  @param user              The user object.
 *  @param completionHandler The handler block to execute.
 */
- (void)unmuteUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unmute user with user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
- (void)unmuteUserWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Return the user is an operator or not.
 *
 *  @param user The user object.
 *
 *  @return If YES, the user is an operator.
 */
- (BOOL)isOperatorWithUser:(SBDUser * _Nonnull)user;

/**
 *  Return the user ID is an operator or not.
 *
 *  @param userId The user ID.
 *
 *  @return If YES, the user ID is an operator.
 */
- (BOOL)isOperatorWithUserId:(NSString * _Nonnull)userId;

@end
