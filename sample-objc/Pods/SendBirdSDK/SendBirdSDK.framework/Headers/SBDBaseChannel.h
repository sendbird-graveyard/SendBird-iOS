//
//  SBDBaseChannel.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/19/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "SBDUser.h"
#import "SBDUserMessage.h"
#import "SBDAdminMessage.h"
#import "SBDFileMessage.h"
#import "SBDError.h"
#import "SBDMember.h"

@class SBDPreviousMessageListQuery;
@class SBDThumbnailSize;
@class SBDThumbnail;
@class SBDFileMessage;
@class SBDUserMessage;
@class SBDMessageListQuery;
@class SBDGroupChannel;
@class SBDOpenChannel;

/**
 *  An object that adopts the `SBDChannelDelegate` protocol is responsible for receiving the events in the channel. Some of delegate methods are common for the `SBDBaseChannel`. However, there are delegate methods for the `SBDOpenChannel` and `SBDGroupChannel` exclusive. The `SBDChannelDelegate` can be added by [`addChannelDelegate:identifier:`](../Classes/SBDMain.html#//api/name/addChannelDelegate:identifier:) in `SBDMain`. Every `SBDChannelDelegate` method which is added is going to receive events. 
 *
 *  @warning If the object that adopts the `SBDChannelDelegate` protocol is invalid, the delegate has to be removed by the identifier via [`removeChannelDelegateForIdentifier:`](../Classes/SBDMain.html#//api/name/removeChannelDelegateForIdentifier:) in `SBDMain`. If you miss this, it will cause the crash.
 *
 *  This protocol deals with the below events.
 *
 *  * Receives a message in the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html).
 *  * Receives an event when a message is updated in the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html).
 *  * Receives an event when a member read a message in the [`SBDGroupChannel`](../Classes/SBDGroupChannel.html).
 *  * Receives an event when a member typed something in the [`SBDGroupChannel`](../Classes/SBDGroupChannel.html).
 *  * Receives an event when a new member joined the [`SBDGroupChannel`](../Classes/SBDGroupChannel.html).
 *  * Receives an event when a member left from the [`SBDGroupChannel`](../Classes/SBDGroupChannel.html).
 *  * Receives an event when a participant entered the [`SBDOpenChannel`](../Classes/SBDOpenChannel.html).
 *  * Receives an event when a participant exited the [`SBDOpenChannel`](../Classes/SBDOpenChannel.html).
 *  * Receives an event when a participant was muted or unmuted in the [`SBDOpenChannel`](../Classes/SBDOpenChannel.html).
 *  * Receives an event when a participant was banned or unbanned in the [`SBDOpenChannel`](../Classes/SBDOpenChannel.html).
 *  * Receives an event when the [`SBDOpenChannel`](../Classes/SBDOpenChannel.html) was frozen or unfrozen.
 *  * Receives an event when the property of the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html) was changed.
 *  * Receives an event when the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html) was deleted.
 *  * Receives an event when a message in the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html) was deleted.
 *  * Receives an event when meta data in the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html) was changed.
 *  * Receives an event when meta counters in the [`SBDBaseChannel`](../Classes/SBDBaseChannel.html) were changed.
 */
@protocol SBDChannelDelegate <NSObject>

@optional

/**
 *  A callback when a message is received.
 *
 *  @param sender The channel where the message is received.
 *  @param message The received message.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender didReceiveMessage:(SBDBaseMessage * _Nonnull)message;


/**
 A callback when a message is updated.

 @param sender The channel where the message is updated.
 @param message The updated message.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender didUpdateMessage:(SBDBaseMessage * _Nonnull)message;

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
 A callback when users are invited by inviter.

 @param sender The group channel where the invitation is occured.
 @param inviter Inviter. It can be nil.
 @param invitees Invitees.
 */
- (void)channel:(SBDGroupChannel * _Nonnull)sender didReceiveInvitation:(NSArray<SBDUser *> * _Nullable)invitees inviter:(SBDUser * _Nullable)inviter;


/**
 A callback when user declined the invitation.

 @param sender The group channel where the invitation is occured.
 @param invitee Inviter. It can be nil.
 @param inviter Invitee.
 */
- (void)channel:(SBDGroupChannel * _Nonnull)sender didDeclineInvitation:(SBDUser * _Nonnull)invitee inviter:(SBDUser * _Nullable)inviter;

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

/**
 A callback when meta data was created in the channel.

 @param sender The channel that the meta data was created.
 @param createdMetaData The created meta data.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender createdMetaData:(NSDictionary<NSString *, NSString *> * _Nullable)createdMetaData;

/**
 A callback when meta data was updated in the channel.

 @param sender The channel that the meta data was updated.
 @param updatedMetaData The updated meta data.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender updatedMetaData:(NSDictionary<NSString *, NSString *> * _Nullable)updatedMetaData;

/**
 A callback when meta data was deleted in the channel.
 
 @param sender The channel that the meta data was deleted.
 @param deletedMetaDataKeys The keys of the deleted meta data.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender deletedMetaDataKeys:(NSArray<NSString *> * _Nullable)deletedMetaDataKeys;

/**
 A callback when meta counters were created in the channel.

 @param sender The channel that the meta counters were created.
 @param createdMetaCounters The created meta counters.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender createdMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nullable)createdMetaCounters;

/**
 A callback when meta counters were updated in the channel.
 
 @param sender The channel that the meta counters were updated.
 @param updatedMetaCounters The updated meta counters.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender updatedMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nullable)updatedMetaCounters;

/**
 A callback when meta counters were deleted in the channel.
 
 @param sender The channel that the meta counters were deleted.
 @param deletedMetaCountersKeys The keys of the deleted meta counters.
 */
- (void)channel:(SBDBaseChannel * _Nonnull)sender deletedMetaCountersKeys:(NSArray<NSString *> * _Nullable)deletedMetaCountersKeys;

@end

/**
 *  The `SBDBaseChannel` class represents the channel where users chat each other. The `SBDOpenChannel` and the `SBDGroupChannel` are derived from this class. This class provides the common methods for the `SBDOpenChannel` and the `SBDGroupChannel`.
 *
 *  * Send a user message to the channel.
 *  * Send a file message to the channel.
 *  * Delete a message of the channel.
 *  * Create a query for loading messages of the channel.
 *  * Manipulate meta counters and meta <span>data</span> of the channel.
 *
 *  The channel objects are maintained as a single instance in an application. If you create or get channels from the same channel URL, they must be the same instances.
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
 *  The custom type of the channel.
 */
@property (strong, nonatomic, nullable) NSString *customType;

- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Sends a user message without <span>data</span>.
 *
 *  @param message           The message text.
 *  @param completionHandler The handler block to execute. `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nullable)message completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a user message without <span>data</span>. The message will be translated into the target languages.
 *
 *  @param message           The message text.
 *  @param targetLanguages   The target languages that the message will be translated into.
 *  @param completionHandler The handler block to execute. `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nullable)message targetLanguages:(NSArray<NSString *> * _Nullable)targetLanguages completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a user message with <span>data</span>.
 *
 *  @param message        The message text.
 *  @param data           The message <span>data</span>.
 *  @param completionHandler The handler block to execute. `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nullable)message data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a user message with <span>data</span>. The message will be translated into the target languages.
 *
 *  @param message        The message text.
 *  @param data           The message <span>data</span>.
 *  @param targetLanguages   The target languages that the message will be translated into.
 *  @param completionHandler The handler block to execute. `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nullable)message data:(NSString * _Nullable)data targetLanguages:(NSArray<NSString *> * _Nullable)targetLanguages completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a user message with <span>data</span> and <span>custom message type</span>.
 *
 *  @param message        The message text.
 *  @param data           The message <span>data</span>.
 *  @param customType     Custom message type.
 *  @param completionHandler The handler block to execute. `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nullable)message data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a user message with <span>data</span> and <span>custom message type</span>. The message will be translated into the target languages.
 *
 *  @param message        The message text.
 *  @param data           The message <span>data</span>.
 *  @param customType     Custom message type.
 *  @param targetLanguages   The target languages that the message will be translated into.
 *  @param completionHandler The handler block to execute. `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDUserMessage *)sendUserMessage:(NSString * _Nullable)message data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType targetLanguages:(NSArray<NSString *> * _Nullable)targetLanguages completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with binary <span>data</span>. The binary <span>data</span> is uploaded to SendBird file storage and a URL of the file will be generated.
 *
 *  @param file              File <span>data</span>.
 *  @param filename          File<span>name</span>.
 *  @param type              The mime type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID and an URL.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID and an URL.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with binary <span>data</span>. The binary <span>data</span> is uploaded to SendBird file storage and a URL of the file will be generated.
 *
 *  @param file              File <span>data</span>.
 *  @param filename          File<span>name</span>.
 *  @param type              The mime type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param customType        Custom message type.
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID and an URL.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID and an URL.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with file URL.
 *
 *  @param url               File URL.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID.
 *
 *  @deprecated in 3.0.29.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithUrl:(NSString * _Nonnull)url size:(NSUInteger)size type:(NSString * _Nonnull)type data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Sends a file message with file URL.
 *
 *  @param url               File URL.
 *  @param filename          File<span>name</span>.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithUrl:(NSString * _Nonnull)url filename:(NSString * _Nullable)filename size:(NSUInteger)size type:(NSString * _Nonnull)type data:(NSString * _Nullable)data completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with file URL and <span>custom message type</span>.
 *
 *  @param url               File URL.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param customType        Custom message type.
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID.
 *
 *  @deprecated in 3.0.29.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithUrl:(NSString * _Nonnull)url size:(NSUInteger)size type:(NSString * _Nonnull)type data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Sends a file message with file URL and <span>custom message type</span>.
 *
 *  @param url               File URL.
 *  @param filename          File<span>name</span>.
 *  @param type              The type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param customType        Custom message type.
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithUrl:(NSString * _Nonnull)url filename:(NSString * _Nullable)filename size:(NSUInteger)size type:(NSString * _Nonnull)type data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with binary <span>data</span>. The binary <span>data</span> is uploaded to SendBird file storage and a URL of the file will be generated. The uploading progress callback can be implemented.
 *
 *  @param file              File <span>data</span>.
 *  @param filename          File<span>name</span>.
 *  @param type              The mime type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param progressHandler   The handler block to monitor progression.  `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body <span>data</span>. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID and an URL.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID and an URL.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size data:(NSString * _Nullable)data progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with binary <span>data</span>. The binary <span>data</span> is uploaded to SendBird file storage and a URL of the file will be generated. The uploading progress callback can be implemented.
 *
 *  @param file              File <span>data</span>.
 *  @param filename          File<span>name</span>.
 *  @param type              The mime type of file.
 *  @param size              File size.
 *  @param data              Custom <span>data</span>.
 *  @param customType        Custom message type.
 *  @param progressHandler   The handler block to monitor progression.  `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body <span>data</span>. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID and an URL.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID and an URL.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with binary <span>data</span>. The binary <span>data</span> is uploaded to SendBird file storage and a URL of the file will be generated. The uploading progress callback can be implemented.
 *
 *  @param file              File <span>data</span>.
 *  @param filename          File<span>name</span>.
 *  @param type              The mime type of file.
 *  @param size              File size.
 *  @param thumbnailSizes    Thumbnail sizes. This parameter is the array of `SBDThumbnailSize` object and works for image file only.
 *  @param data              Custom <span>data</span>.
 *  @param customType        Custom message type.
 *  @param progressHandler   The handler block to monitor progression.  `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body <span>data</span>. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID and an URL.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID and an URL.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithBinaryData:(NSData * _Nonnull)file filename:(NSString * _Nonnull)filename type:(NSString * _Nonnull)type size:(NSUInteger)size thumbnailSizes:(NSArray<SBDThumbnailSize *> * _Nullable)thumbnailSizes data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Sends a file message with binary <span>data</span>. The binary <span>data</span> is uploaded to SendBird file storage and a URL of the file will be generated. The uploading progress callback can be implemented.
 *
 *  @param filepath          File path to be sent.
 *  @param type              The mime type of file.
 *  @param thumbnailSizes    Thumbnail sizes. This parameter is the array of `SBDThumbnailSize` object and works for image file only.
 *  @param data              Custom <span>data</span>.
 *  @param customType        Custom message type.
 *  @param progressHandler   The handler block to monitor progression.  `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body <span>data</span>. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute. `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID and an URL.
 *
 *  @return Returns the temporary file message with a request ID. It doesn't have a message ID and an URL.
 */
- (nonnull SBDFileMessage *)sendFileMessageWithFilePath:(NSString * _Nonnull)filepath type:(NSString * _Nonnull)type thumbnailSizes:(NSArray<SBDThumbnailSize *> * _Nullable)thumbnailSizes data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

#pragma mark - Load message list
/**
 *  Creates `SBDPreviousMessageListQuery` instance for getting the previous messages list of the channel.
 *
 *  @return Returns the message list of the channel.
 */
- (nullable SBDPreviousMessageListQuery *)createPreviousMessageListQuery;

/**
 *  Creates `SBDMessageListQuery` instance for getting the previous messages list of the channel.
 *
 *  @return Returns the message list of the channel.
 *
 *  @deprecated in 3.0.28.
 */
- (nullable SBDMessageListQuery *)createMessageListQuery DEPRECATED_ATTRIBUTE;

#pragma mark - Meta Counters
/**
 *  Creates the meta counters for the channel.
 *
 *  @param metaCounters      The meta counters to be set.
 *  @param completionHandler The handler block to execute. `metaCounters` is the meta counters which are set on SendBird server.
 */
- (void)createMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the meta counters with keys for the channel.
 *
 *  @param keys              The keys to get meta counters.
 *  @param completionHandler The handler block to execute. `metaCounters` is the meta counters which are set on SendBird server.
 */
- (void)getMetaCountersWithKeys:(NSArray<NSString *> * _Nullable)keys completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Gets all meta counters for the channel.
 *
 *  @param completionHandler The handler block to execute. `metaCounters` is the meta counters which are returned from SendBird server.
 */
- (void)getAllMetaCountersWithCompletionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Updates the meta counters for the channel.
 *
 *  @param metaCounters      The meta counters to be updated.
 *  @param completionHandler The handler block to execute. `metaCounters` is the meta counters which are updated on SendBird server.
 */
- (void)updateMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Increases the meta counters for the channel.
 *
 *  @param metaCounters      The meta counters to be increased.
 *  @param completionHandler The handler block to execute. `metaCounters` is the meta counters which are increased on SendBird server.
 */
- (void)increaseMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Decreases the meta counters for the channel.
 *
 *  @param metaCounters      The meta counters to be decreased.
 *  @param completionHandler The handler block to execute. `metaCounters` is the meta counters which are decreased on SendBird server.
 */
- (void)decreaseMetaCounters:(NSDictionary<NSString *, NSNumber *> * _Nonnull)metaCounters completionHandler:(nullable void (^)(NSDictionary<NSString *, NSNumber *> * _Nullable metaCounters, SBDError * _Nullable error))completionHandler;

/**
 *  Deletes the meta counters with key for the channel.
 *
 *  @param key               The key to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMetaCountersWithKey:(NSString * _Nonnull)key completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Deletes all meta counters for the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteAllMetaCountersWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

#pragma mark - Meta Data
/**
 *  Creates the meta <span>data</span> for the channel.
 *
 *  @param metaData          The meta <span>data</span> to be set.
 *  @param completionHandler The handler block to execute. `metaData` is the meta <span>data</span> which are set on SendBird server.
 */
- (void)createMetaData:(NSDictionary<NSString *, NSString *> * _Nonnull)metaData completionHandler:(nullable void (^)(NSDictionary<NSString *, NSString *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the meta <span>data</span> for the channel.
 *
 *  @param keys              The keys to get meta <span>data</span>.
 *  @param completionHandler The handler block to execute. `metaData` is the meta <span>data</span> which are set on SendBird server.
 */
- (void)getMetaDataWithKeys:(NSArray<NSString *> * _Nullable)keys completionHandler:(nullable void (^)(NSDictionary<NSString *, NSObject *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Gets all meta <span>data</span> for the channel.
 *
 *  @param completionHandler The handler block to execute. `metaData` is the meta <span>data</span> which are set on SendBird server.
 */
- (void)getAllMetaDataWithCompletionHandler:(nullable void (^)(NSDictionary<NSString *, NSObject *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Updates the meta <span>data</span> for the channel.
 *
 *  @param metaData          The meta <span>data</span> to be updated.
 *  @param completionHandler The handler block to execute. `metaData` is the meta counters which are updated on SendBird server.
 */
- (void)updateMetaData:(NSDictionary<NSString *, NSString *> * _Nonnull)metaData completionHandler:(nullable void (^)(NSDictionary<NSString *, NSObject *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Deletes meta <span>data</span> with key for the channel.
 *
 *  @param key               The key to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMetaDataWithKey:(NSString * _Nonnull)key completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Deletes all meta <span>data</span> for the channel.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteAllMetaDataWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Deletes a message. The message's sender has to be the current user.
 *
 *  @param message           The message to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMessage:(SBDBaseMessage * _Nonnull)message completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;


/**
 *  Updates a user message. The message text, data, and custom type can be updated.
 *
 *  @param userMessage       The user message to be updated.
 *  @param messageText       New message text.
 *  @param data              New data.
 *  @param customType        New custom type.
 *  @param completionHandler The handler block to execute.
 */
- (void)updateUserMessage:(SBDUserMessage * _Nonnull)userMessage messageText:(NSString * _Nullable)messageText data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Updates a file message. The data and custom type can be updated.
 *
 *  @param fileMessage       The file message to be updated.
 *  @param data              New data.
 *  @param customType        New custom type.
 *  @param completionHandler The handler block to execute.
 */
- (void)updateFileMessage:(SBDFileMessage * _Nonnull)fileMessage data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error))completionHandler;

/**
 *  Checks the channel type.
 *
 *  @return If YES, this channel is a group channel.
 */
- (BOOL)isGroupChannel;

/**
 *  Checks the channel type.
 *
 *  @return If YES, this channel is an open channel.
 */
- (BOOL)isOpenChannel;

#pragma mark - Get messages by timestamp.
/**
 *  Gets the next messages by the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in v3.0.40.
 */
- (void)getNextMessagesByTimestamp:(long long)timestamp limit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Gets the next messages by the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param messageType       Message type to filter messages.
 *  @param customType        Custom type to filter messages. If filtering isn't required, set nil.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)getNextMessagesByTimestamp:(long long)timestamp limit:(NSInteger)limit reverse:(BOOL)reverse messageType:(SBDMessageTypeFilter)messageType customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the previous messages by the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in v3.0.40.
 */
- (void)getPreviousMessagesByTimestamp:(long long)timestamp limit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Gets the previous messages by the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param messageType       Message type to filter messages.
 *  @param customType        Custom type to filter messages. If filtering isn't required, set nil.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)getPreviousMessagesByTimestamp:(long long)timestamp limit:(NSInteger)limit reverse:(BOOL)reverse messageType:(SBDMessageTypeFilter)messageType customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the previous and next message by the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param prevLimit         The previous limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param nextLimit         The next limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in v3.0.40.
 */
- (void)getPreviousAndNextMessagesByTimestamp:(long long)timestamp prevLimit:(NSInteger)prevLimit nextLimit:(NSInteger)nextLimit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Gets the previous and next message by the timestamp with a limit and ordering.
 *
 *  @param timestamp         The standard timestamp to load messages.
 *  @param prevLimit         The previous limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param nextLimit         The next limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param messageType       Message type to filter messages.
 *  @param customType        Custom type to filter messages. If filtering isn't required, set nil.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)getPreviousAndNextMessagesByTimestamp:(long long)timestamp prevLimit:(NSInteger)prevLimit nextLimit:(NSInteger)nextLimit reverse:(BOOL)reverse messageType:(SBDMessageTypeFilter)messageType customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

#pragma mark - Get messages by message ID.
/**
 *  Gets the next messages by the message ID with a limit and ordering.
 *
 *  @param messageId         The standard message ID to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in v3.0.40.
 */
- (void)getNextMessagesByMessageId:(long long)messageId limit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Gets the next messages by the message ID with a limit and ordering.
 *
 *  @param messageId         The standard message ID to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param messageType       Message type to filter messages.
 *  @param customType        Custom type to filter messages. If filtering isn't required, set nil.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)getNextMessagesByMessageId:(long long)messageId limit:(NSInteger)limit reverse:(BOOL)reverse messageType:(SBDMessageTypeFilter)messageType customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the previous messages by the message ID with a limit and ordering.
 *
 *  @param messageId         The standard message ID to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in v3.0.40.
 */
- (void)getPreviousMessagesByMessageId:(long long)messageId limit:(NSInteger)limit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Gets the previous messages by the message ID with a limit and ordering.
 *
 *  @param messageId         The standard message ID to load messages.
 *  @param limit             The limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param messageType       Message type to filter messages.
 *  @param customType        Custom type to filter messages. If filtering isn't required, set nil.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)getPreviousMessagesByMessageId:(long long)messageId limit:(NSInteger)limit reverse:(BOOL)reverse messageType:(SBDMessageTypeFilter)messageType customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the previous and next message by the message ID with a limit and ordering.
 *
 *  @param messageId         The standard message ID to load messages.
 *  @param prevLimit         The previous limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param nextLimit         The next limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 *
 *  @deprecated in v3.0.40.
 */
- (void)getPreviousAndNextMessagesByMessageId:(long long)messageId prevLimit:(NSInteger)prevLimit nextLimit:(NSInteger)nextLimit reverse:(BOOL)reverse completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Gets the previous and next message by the message ID with a limit and ordering.
 *
 *  @param messageId         The standard message ID to load messages.
 *  @param prevLimit         The previous limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param nextLimit         The next limit for the number of messages. The returned messages could be more than this number if there are messages which have the same timestamp.
 *  @param reverse           If yes, the latest message is the index 0.
 *  @param messageType       Message type to filter messages.
 *  @param customType        Custom type to filter messages. If filtering isn't required, set nil.
 *  @param completionHandler The handler block to execute. The `messages` is the array of `SBDBaseMessage` instances.
 */
- (void)getPreviousAndNextMessagesByMessageId:(long long)messageId prevLimit:(NSInteger)prevLimit nextLimit:(NSInteger)nextLimit reverse:(BOOL)reverse messageType:(SBDMessageTypeFilter)messageType customType:(NSString * _Nullable)customType completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error))completionHandler;

/**
 Builds a base channel object from serialized <span>data</span>.
 
 @param data Serialized <span>data</span>.
 @return SBDBaseChannel object.
 */
+ (nullable instancetype)buildFromSerializedData:(NSData * _Nonnull)data;

/**
 Serializes base channel object.
 
 @return Serialized <span>data</span>.
 */
- (nullable NSData *)serialize;

/**
 Cancels the file message uploading.
 
 @param requestId The request ID of the file message that is been uploading.
 @param completionHandler The handler block to execute. If the `result` is `YES`, then the uploading task of the `requestId` has been cancelled.
 */
+ (void)cancelUploadingFileMessageWithRequestId:(NSString * _Nonnull)requestId completionHandler:(nullable void (^)(BOOL result, SBDError * _Nullable error))completionHandler;


/**
 Copies a user message to the target channel.

 @param message User message object.
 @param targetChannel Target channel object.
 @param completionHandler The handler block to execute. The `userMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 @return Returns the temporary user message with a request ID. It doesn't have a message ID.
 */
- (SBDUserMessage * _Nullable)copyUserMessage:(SBDUserMessage * _Nonnull)message toTargetChannel:(SBDBaseChannel * _Nonnull)targetChannel completionHandler:(nullable void (^)(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error))completionHandler;


/**
 Copies a file message to the target channel.

 @param message File message object.
 @param targetChannel Target channel object.
 @param completionHandler The handler block to execute. The `fileMessage` is a user message which is returned from the SendBird server. The message has a message ID.
 @return Returns the temporary file message with a request ID. It doesn't have a message ID.
 */
- (SBDFileMessage * _Nullable)copyFileMessage:(SBDFileMessage * _Nonnull)message toTargetChannel:(SBDBaseChannel * _Nonnull)targetChannel completionHandler:(nullable void (^)(SBDFileMessage * _Nullable fileMessage,  SBDError * _Nullable error))completionHandler;


/**
 Gets the changelogs of the messages with token.

 @param token The token that is used to get more changelogs.
 @param completionHandler The handler block to execute. The `updatedMessages` is the messages that were updated. The `deletedMessageIds` is the list of the deleted message IDs. If there are more changelogs that are not returned yet, the `hasMore` is YES. The `token` can be used to get more changedlogs.
 */
- (void)getMessageChangeLogsWithToken:(NSString * _Nullable)token completionHandler:(nullable void (^)(NSArray<SBDBaseMessage *> * _Nullable updatedMessages, NSArray<NSNumber *> * _Nullable deletedMessageIds, BOOL hasMore, NSString * _Nullable token, SBDError * _Nullable error))completionHandler;

/**
 *  Internal use only.
 */
- (nullable NSDictionary *)_toDictionary;

@end
