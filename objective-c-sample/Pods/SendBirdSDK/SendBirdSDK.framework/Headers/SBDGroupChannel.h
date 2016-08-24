//
//  SBDGroupChannel.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDBaseChannel.h"
#import "SBDGroupChannelListQuery.h"
#import "SBDBaseMessage.h"
#import "SBDUser.h"

@class SBDUser;
@class SBDGroupChannel;
@class SBDGroupChannelListQuery;

/**
 * Represents a group channel.
 */
@interface SBDGroupChannel : SBDBaseChannel

/**
 *  Last message of the channel.
 */
@property (strong, nonatomic, nullable) SBDBaseMessage *lastMessage;

/**
 *  Represent the channel is distinct or not.
 */
@property (atomic) BOOL isDistinct;

/**
 *  Unread message count of the channel.
 */
@property (atomic) NSUInteger unreadMessageCount;

/**
 *  Channel members.
 */
@property (strong, nonatomic, readonly, nullable) NSMutableArray<SBDUser *> *members;

/**
 *  The number of members.
 */
@property (atomic, readonly) NSUInteger memberCount;

/**
 *  The flag for sending mark as read.
 */
@property (atomic) BOOL sendMarkAsReadEnable;

/**
 *  Refresh this instance.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)refreshWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Initialize instance with dictionary of group channel.
 *
 *  @param dict The dictionary of group channel.
 *
 *  @return The instance of group channel.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Create a query for my group channel list.
 *
 *  @return SBDGroupChannelListQuery instance for the current user.
 */
+ (nullable SBDGroupChannelListQuery *)createMyGroupChannelListQuery;

/**
 *  Create a group channel with user objects.
 *
 *  @param users             The users to be members of the channel.
 *  @param isDistinct        If YES, the channel which has the same users is returned.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithUsers:(NSArray<SBDUser *> * _Nonnull)users isDistinct:(BOOL)isDistinct completionHandler:(nonnull void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create a group channel with user objects.
 *
 *  @param userIds           The user IDs to be members of the channel.
 *  @param isDistinct        If YES, the channel which has the same users is returned.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithUserIds:(NSArray<NSString *> * _Nonnull)userIds isDistinct:(BOOL)isDistinct completionHandler:(nonnull void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create a group channel with user objects.
 *
 *  @param name              The name of group channel.
 *  @param users             The users to be members of the channel.
 *  @param coverUrl          The cover image url of group channel.
 *  @param data              The custom data of group channel.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name users:(NSArray<SBDUser *> * _Nonnull)users coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data completionHandler:(nonnull void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create a group channel with user IDs.
 *
 *  @param name              The name of group channel.
 *  @param userIds           The user IDs to participate the channel.
 *  @param coverUrl          The cover image url of group channel.
 *  @param data              The custom data of group channel.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name userIds:(NSArray<NSString *> * _Nonnull)userIds coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data completionHandler:(nonnull void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create a group channel with user objects.
 *
 *  @param name              The name of group channel.
 *  @param isDistinct        If YES, the channel which has the same users is returned.
 *  @param users             The users to participate the channel.
 *  @param coverUrl          The cover image url of group channel.
 *  @param data              The custom data of group channel.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name isDistinct:(BOOL)isDistinct users:(NSArray<SBDUser *> * _Nonnull)users coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data completionHandler:(nonnull void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Create a group channel with user IDs.
 *
 *  @param name              The name of group channel.
 *  @param isDistinct        If YES, the channel which has the same users is returned.
 *  @param userIds           The user IDs to participate the channel.
 *  @param coverUrl          The cover image url of group channel.
 *  @param data              The custom data of group channel.
 *  @param completionHandler The handler block to execute.
 */
+ (void)createChannelWithName:(NSString * _Nullable)name isDistinct:(BOOL)isDistinct userIds:(NSArray<NSString *> * _Nonnull)userIds coverUrl:(NSString * _Nullable)coverUrl data:(NSString * _Nullable)data completionHandler:(nonnull void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Get a group channel instance from channel URL asynchronously.
 *
 *  @param channelUrl        The channel URL.
 *  @param completionHandler The handler block to execute.
 */
+ (void)getChannelWithUrl:(NSString * _Nonnull)channelUrl completionHandler:(nullable void (^)(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error))completionHandler;

/**
 *  Invite a user to the group channel.
 *
 *  @param user              The user to be invited.
 *  @param completionHandler The handler block to execute.
 */
- (void)inviteUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Invite a user to the group channel.
 *
 *  @param userId            The user ID to be invited.
 *  @param completionHandler The handler block to execute.
 */
- (void)inviteUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Invite users to the group channel.
 *
 *  @param users             The user array to be invited.
 *  @param completionHandler The handler block to execute.
 */
- (void)inviteUsers:(NSArray<SBDUser *> * _Nonnull)users completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Invite users to the group channel.
 *
 *  @param userIds           The IDs of users array to be invited.
 *  @param completionHandler The handler block to execute.
 */
- (void)inviteUserIds:(NSArray<NSString *> * _Nonnull)userIds completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Hide the group channel. The channel will be hid from the channel list, but it will be appeared when the other user send a message.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)hideChannelWithCompletionHandler:(nullable void (^)(SBDError *_Nullable error))completionHandler;

/**
 *  Leave the group channel. The channel will be disappeared from the channel list. If join the channel, the invitation is required.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)leaveChannelWithCompletionHandler:(nullable void (^)(SBDError *_Nullable error))completionHandler;

/**
 *  Mark as read all group channels of the current user.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)markAsReadAllWithCompletionHandler:(nullable void (^)(SBDError *_Nullable error))completionHandler;

//- (void)markAsReadWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Internal use only.
 */
+ (void)_markAsRead;

/**
 *  Send mark as read.
 */
- (void)markAsRead;

/**
 *  Start typing.
 */
- (void)startTyping;

/**
 *  End typing.
 */
- (void)endTyping;

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
 *  Get channel object from cache.
 *
 *  @param channelUrl The channel URL.
 *
 *  @return The channel object.
 */
+ (SBDGroupChannel * _Nullable)getChannelFromCacheWithChannelUrl:(NSString * _Nonnull)channelUrl;

/**
 *  Returns how many members haven't been read for the given message.
 *
 *  @param message The message.
 *
 *  @return Number of unread member count. Zero if all members read the message.
 */
- (int)getReadReceiptOfMessage:(SBDBaseMessage * _Nonnull)message;

/**
 *  If other users are typing in the channel, YES is returned.
 *
 *  @return Returns YES when other users are typing in this channel.
 */
- (BOOL)isTyping;

/**
 *  Returns the members who are typing now.
 *
 *  @return The members who are typing now.
 */
- (nullable NSArray<SBDUser *> *)getTypingMembers;

/**
 *  Update read receipt with user ID.
 *
 *  @param userId    The user ID who read a message.
 *  @param timestamp The timestamp when the user read a message.
 */
- (void)updateReadReceiptWithUserId:(NSString * _Nonnull)userId timestamp:(long long)timestamp;

/**
 *  Update typing status with user.
 *
 *  @param user  The user who is typing.
 *  @param start The timestamp when the typing is started.
 */
- (void)updateTypingStatusWithUser:(SBDUser * _Nonnull)user start:(BOOL)start;

/**
 *  Add a user to member list of the channel.
 *
 *  @param user The user to be added to member list.
 */
- (void)addMember:(SBDUser * _Nonnull)user;

/**
 *  Remove a user from member list of the channel.
 *
 *  @param user The user to be removed from member list.
 */
- (void)removeMember:(SBDUser * _Nonnull)user;

- (void)typingStatusTimeout;

+ (void)updateTypingStatus;

@end
