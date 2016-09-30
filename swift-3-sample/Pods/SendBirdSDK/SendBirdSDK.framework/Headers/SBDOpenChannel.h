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
 *  The `SBDOpenChannel` class represents a public chat. This is a channel type which anyone can participate without a permission. It can handle thousands of users in one channel. This channel has participants instead of members of `SBDGroupChannel` and every participant is always online. A user can be included as an operator when a channel is created. The operator has a permission to mute, unmute, ban and unban participants. The muted user can see the messages in the channel, but can't say anything. The unbanned user can't enter the channel. If a user who is in the channel is banned, the user will be kicked from the channel.
 */
@interface SBDOpenChannel : SBDBaseChannel

/**
 *  The number of participants in this channel.
 */
@property (nonatomic) NSInteger participantCount;

/**
 *  The operators of this channel.
 */
@property (strong, nonatomic, readonly, nullable) NSMutableArray<SBDUser *> *operators;

/**
 *  Internal use only.
 */
+ (void)clearCache;

/**
 *  Internal use only.
 */
+ (void)removeChannelFromCacheWithChannelUrl:(NSString * _Nonnull)channelUrl;

/**
 *  Initializes this channel instance with dictionary of open channel.
 *
 *  @param dict The dictionary of open channel.
 *
 *  @return The instance of open channel.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Creates a query instance for open channel list.
 *
 *  @return The query instance for open channel list.
 */
+ (nullable SBDOpenChannelListQuery *)createOpenChannelListQuery;

/**
 *  Creates an open channel.
 *
 *  @param completionHandler The handler block to execute. `channel` is the open channel instance which is created. The name and cover URL of the channel are generated in SendBird server.
 */
+ (void)createChannelWithCompletionHandler:(nonnull void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Creates an open channel with properties.
 *
 *  @param name              The name of the channel.
 *  @param coverUrl          The cover image URL.
 *  @param data              The data for channel.
 *  @param operatorUsers     The operator users of channel.
 *  @param completionHandler The handler block to execute. `channel` is the open channel instance which is created.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data operatorUsers:(NSArray<SBDUser *> * _Nullable)operatorUsers completionHandler:(nonnull void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Creates an open channel.
 *
 *  @param name              The name of the channel.
 *  @param coverUrl          The cover image URL.
 *  @param data              The data for channel.
 *  @param operatorUserIds   The operator user IDs of channel.
 *  @param completionHandler The handler block to execute. `channel` is the open channel instance which is created.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data operatorUserIds:(NSArray<NSString *> * _Nullable)operatorUserIds completionHandler:(nonnull void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Gets an open channel instance from channel URL.
 *
 *  @param channelUrl        The channel URL.
 *  @param completionHandler The handler block to execute. `channel` is the open channel instance which has the `channelUrl`.
 */
+ (void)getChannelWithUrl:(NSString * _Nonnull)channelUrl completionHandler:(nullable void (^)(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Enters the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)enterChannelWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Exits the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)exitChannelWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Creates a query instance for getting participant list of the channel instance.
 *
 *  @return SBDUserListQuery instance for the participant list of the channel instance.
 */
- (nullable SBDUserListQuery *)createParticipantListQuery;

/**
 *  Creates a query instance for getting muted user list of the channel instance.
 *
 *  @return SBDUserListQuery instance for the muted user list.
 */
- (nullable SBDUserListQuery *)createMutedUserListQuery;

/**
 *  Creates a query instance for getting banned user list of the channel instance.
 *
 *  @return SBDUserListQuery instance for the banned user list.
 */
- (nullable SBDUserListQuery *)createBannedUserListQuery;

/**
 *  Refreshes the channel information.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)refreshWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Internal use only.
 */
+ (nullable NSMutableDictionary<NSString *, SBDOpenChannel *> *)enteredChannels;

/**
 *  Bans a user with the user object.
 *
 *  @param user              The user object.
 *  @param seconds           Duration for ban in seconds.
 *  @param completionHandler The handler block to execute.
 */
- (void)banUser:(SBDUser * _Nonnull)user seconds:(int)seconds completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Bans a user with the user ID.
 *
 *  @param userId            The user ID.
 *  @param seconds           Duration for ban in seconds.
 *  @param completionHandler The handler block to execute.
 */
- (void)banUserWithUserId:(NSString * _Nonnull)userId seconds:(int)seconds completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unbans a user with the user object.
 *
 *  @param user              The user object.
 *  @param completionHandler The handler block to execute.
 */
- (void)unbanUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unbans a user with the user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
- (void)unbanUserWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Mutes auser with the user object.
 *
 *  @param user              The user object.
 *  @param completionHandler The handler block to execute.
 */
- (void)muteUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Mutes a user with the user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
- (void)muteUserWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unmutes a user with the user object.
 *
 *  @param user              The user object.
 *  @param completionHandler The handler block to execute.
 */
- (void)unmuteUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unmutes a user with the user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
- (void)unmuteUserWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Returns the user is an operator or not.
 *
 *  @param user The user object.
 *
 *  @return If YES, the user is an operator.
 */
- (BOOL)isOperatorWithUser:(SBDUser * _Nonnull)user;

/**
 *  Returns the user ID is an operator or not.
 *
 *  @param userId The user ID.
 *
 *  @return If YES, the user ID is an operator.
 */
- (BOOL)isOperatorWithUserId:(NSString * _Nonnull)userId;

@end
