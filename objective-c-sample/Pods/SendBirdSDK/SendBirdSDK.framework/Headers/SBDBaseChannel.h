//
//  SBDBaseChannel.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/19/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"
#import "SBDUserMessage.h"
#import "SBDAdminMessage.h"
#import "SBDFileMessage.h"
#import "SBDError.h"

@class SBDPreviousMessageListQuery;
@class SBDFileMessage;
@class SBDUserMessage;
@class SBDMessageListQuery;
@class SBDGroupChannel;
@class SBDOpenChannel;

/**
 *  Channe delegates. 
 */
@protocol SBDChannelDelegate <NSObject>

@optional

/**
 *  A callback when a message received.
 *
 *  @param sender The channel where the message is received.
 *  @param message The received message.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message;

/**
 *  A callback when read receipts updated.
 *
 *  @param sender The group channel where the read receipt updated.
 */
- (void)channelDidUpdateReadReceipt:(SBDGroupChannel * _Nonnull)sender;

/**
 *  A callback when user sends typing status.
 *
 *  @param sender The group channel where the typing status updated.
 */
- (void)channelDidUpdateTypingStatus:(SBDGroupChannel * _Nonnull)sender;

/**
 *  A callback when new member joined to the group channel.
 *
 *  @param sender The group channel.
 *  @param user   The new user joined to the channel.
 */
- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidJoin:(SBDUser * _Nonnull)user;

/**
 *  A callback when current member left from the group channel.
 *
 *  @param sender The group channel.
 *  @param user   The member left from the channel.
 */
- (void)channel:(SBDGroupChannel * _Nonnull)sender userDidLeave:(SBDUser * _Nonnull)user;

/**
 *  A callback when a user enter an open channel.
 *
 *  @param sender The open channel.
 *  @param user   The user
 */
- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidEnter:(SBDUser * _Nonnull)user;

/**
 *  A callback when a user exit an open channel.
 *
 *  @param sender The open channel.
 *  @param user   The user.
 */
- (void)channel:(SBDOpenChannel * _Nonnull)sender userDidExit:(SBDUser * _Nonnull)user;

/**
 *  A callback when a user was muted in the open channel.
 *
 *  @param sender The open channel.
 *  @param user   The user who was muted.
 */
- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasMuted:(SBDUser * _Nonnull)user;

/**
 *  A callback when a user was unmuted in the open channel.
 *
 *  @param sender The open channel.
 *  @param user   The user who was unmuted.
 */
- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnmuted:(SBDUser * _Nonnull)user;

/**
 *  A callback when a user was banned in the open channel.
 *
 *  @param sender The open channel.
 *  @param user   The user who was banned.
 */
- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasBanned:(SBDUser * _Nonnull)user;

/**
 *  A callback when a user was unbanned in the open channel.
 *
 *  @param sender The open channel.
 *  @param user   The user who was unbanned.
 */
- (void)channel:(SBDOpenChannel * _Nonnull)sender userWasUnbanned:(SBDUser * _Nonnull)user;

/**
 *  A callback when an open channel was frozen.
 *
 *  @param sender The open channel.
 */
- (void)channelWasFrozen:(SBDOpenChannel * _Nonnull)sender;

/**
 *  A callback when an open channel was unfrozen.
 *
 *  @param sender The open channel.
 */
- (void)channelWasUnfrozen:(SBDOpenChannel * _Nonnull)sender;

/**
 *  A callback when an open channel was changed.
 *
 *  @param sender The open channel.
 */
- (void)channelWasChanged:(SBDBaseChannel * _Nonnull)sender;

/**
 *  A callback when an open channel was deleted.
 *
 *  @param channelUrl The open channel.
 */
- (void)channelWasDeleted:(NSString * _Nonnull)channelUrl channelType:(SBDChannelType)channelType;

/**
 *  A callback when a message was removed in the channel.
 *
 *  @param sender    The base channel.
 *  @param messageId The message ID which was removed.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender messageWasDeleted:(long long)messageId;

@end

/**
 * Objects representing a channel.
 */
@interface SBDBaseChannel : NSObject

/**
 *  The channel URL.
 */
@property (strong, nonatomic, nonnull) NSString *channelUrl;

/**
 *  The name of channel.
 */
@property (strong, nonatomic, nonnull) NSString *name;

/**
 *  The channel cover image URL.
 */
@property (strong, nonatomic, nullable) NSString *coverUrl;

/**
 *  The timestamp when the channel is created.
 */
@property (atomic) NSUInteger createdAt;

/**
 *  The custom date of the channel.
 */
@property (strong, nonatomic, nullable) NSString *data;

/**
 *  Initialize object.
 *
 *  @param dict Dictionary data.
 *
 *  @return SBDBaseChannel object.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Send a user message without data.
 *
 *  @param message           The message text.
 *  @param completionHandler The handler block to execute.
 *
 *  @return Returns the user message which has request id.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nonnull)message completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Send a user message.
 *
 *  @param message        The message text.
 *  @param data           The message data.
 *  @param completionHandler The handler block to execute.
 *
 *  @return Returns the user message which has request id.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nonnull)message data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Send a file message with binary data.
 *
 *  @param file              File data.
 *  @param filename          Filename.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom data.
 *  @param completionHandler The handler block to execute.
 *
 *  @return Returns the file message which has request id.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Send a file message with file URL.
 *
 *  @param url               File URL.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom data.
 *  @param completionHandler The handler block to execute.
 *
 *  @return Returns the file message which has request id.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithUrl:(NSString * _Nonnull)url size:(NSUInteger)size type:(NSString * _Nonnull)type data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Send a file message with binary data. The progress callback can be implemented.
 *
 *  @param file              File data.
 *  @param filename          Filename.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom data.
 *  @param progressHandler   The handler block to monitor progression.
 *  @param completionHandler The handler block to execute.
 *
 *  @return Returns the file message which has request id.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size data:(NSString * _Nullable)data progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

#pragma mark - Load message list
/**
 *  Create a query instance for getting previous message list of the channel instance.
 *
 *  @return The message list of the channel instance.
 */
- (nullable SBDPreviousMessageListQuery *)createPreviousMessageListQuery;

/**
 *  Create a query for getting message list of the channel instance.
 *
 *  @return The message list of the channel instance.
 */
- (nullable SBDMessageListQuery *)createMessageListQuery;

#pragma mark - Meta Counters
/**
 *  Create meta counters for the channel.
 *
 *  @param metaCounters       The meta counters to be set.
 *  @param completionHandler The handler block to execute.
 */
- (void)createMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Get meta counters with keys for the channel.
 *
 *  @param keys              The keys to get meta counters.
 *  @param completionHandler The handler block to execute.
 */
- (void)getMetaCountersWithKeys:(NSArray<NSString *> * _Nullable)keys completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Get all meta counters for the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)getAllMetaCountersWithCompletionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Update meta counters for the channel.
 *
 *  @param metaCounters       The meta counters to be updated.
 *  @param completionHandler The handler block to execute.
 */
- (void)updateMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Increase meta counters for the channel.
 *
 *  @param metaCounters       The meta counters to be increased.
 *  @param completionHandler The handler block to execute.
 */
- (void)increaseMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Decrease meta counters for the channel.
 *
 *  @param metaCounters       The meta counters to be decreased.
 *  @param completionHandler The handler block to execute.
 */
- (void)decreaseMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Delete meta counters with key for the channel.
 *
 *  @param key               The key to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMetaCountersWithKey:(NSString * _Nonnull)key completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Delete all meta counters for the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteAllMetaCountersWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

#pragma mark - Meta Data
/**
 *  Create meta data for the channel.
 *
 *  @param metaData       The meta data to be set.
 *  @param completionHandler The handler block to execute.
 */
- (void)createMetaData:(NSDictionary<NSString *, NSString *> * _Nonnull)metaData completionHandler:(nullable void (^)(NSDictionary<NSString *, NSString *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Get meta data for the channel.
 *
 *  @param keys              The keys to get meta data.
 *  @param completionHandler The handler block to execute.
 */
- (void)getMetaDataWithKeys:(NSArray<NSString *> * _Nullable)keys completionHandler:(nullable void (^)(NSDictionary<NSString *, NSObject *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Get all meta data for the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)getAllMetaDataWithCompletionHandler:(nullable void (^)(NSDictionary<NSString *, NSObject *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Update meta data for the channel.
 *
 *  @param metaData          The meta data to be updated.
 *  @param completionHandler The handler block to execute.
 */
- (void)updateMetaData:(NSDictionary<NSString *, NSString *> * _Nonnull)metaData completionHandler:(nullable void (^)(NSDictionary<NSString *, NSObject *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Delete meta data with key for the channel.
 *
 *  @param key               The key to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMetaDataWithKey:(NSString * _Nonnull)key completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Delete all meta data for the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteAllMetaDataWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Delete a message. The message's sender has to be the current user.
 *
 *  @param message           The message to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMessage:(SBDBaseMessage * _Nonnull)message completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Check the channel type.
 *
 *  @return If YES, this channel is group channel.
 */
- (BOOL)isGroupChannel;

/**
 *  Check the channel type.
 *
 *  @return If YES, this channel is open channel.
 */
- (BOOL)isOpenChannel;

@end
