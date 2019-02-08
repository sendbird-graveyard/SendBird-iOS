//
//  SBDMain.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SBDUser.h"
#import "SBDBaseChannel.h"
#import "SBDGroupChannel.h"
#import "SBDOpenChannelListQuery.h"
#import "SBDGroupChannelListQuery.h"
#import "SBDTypes.h"
#import "SBDUserListQuery.h"
#import "SBDInternalTypes.h"
#import "SBDFriendListQuery.h"
#import "SBDApplicationUserListQuery.h"
#import "SBDBlockedUserListQuery.h"

typedef void(^SBDBackgroundSessionBlock)(void);

/**
 Represents operation options.
 */
@interface SBDOptions : NSObject

/**
 Gets the value whether the sender information of `sender` of `SBDUserMessage` or `SBDFileMessage` such as nickname and profile url will be returned as the latest user's or not.
 
 @return If YES, the sender is the latest information.
 */
+ (BOOL)useMemberAsMessageSender;

/**
 If set <code>YES</code>, the sender information of `sender` of `SBDUserMessage` or `SBDFileMessage` such as nickname and profile url will be returned as the latest user's. Otherwise, the information will be the value of the message creation time.
 
 @param tf <code>YES</code> or <code>NO</code>.
 */
+ (void)setUseMemberAsMessageSender:(BOOL)tf;


/**
 Sets the timeout for connection. If there is a timeout error frequently, set the longer timeout than default value. The default is 10 seconds.
 
 @param timeout The timeout for connection.
 */
+ (void)setConnectionTimeout:(NSInteger)timeout;

/**
 *  Sets a term of typing indicator throttling in group channel.
 *  After this throttling interval from typing indicator started (or ended), You can re-start (or re-end) typing indicator.
 *  If you call start (or end) again in this interval, the call will be ignored.
 *
 *  @param interval  A time interval that can renew typing indicator. can be RANGE from 1.0 to 9.0.
 *  @since 3.0.100
 */
+ (void)setTypingIndicatorThrottle:(NSTimeInterval)interval;

/**
 Sets the authentication timeout managed by `authenticateWithAuthInfoRequestHandler:completionHandler:` of `SBDConnectionManager`. The default value is 10 seconds.

 @param timeout Timeout in seconds. It must be greater than 0. Otherwise, the default value (10 seconds) will be set.
 @since 3.0.109
 */
+ (void)setAuthenticationTimeout:(NSTimeInterval)timeout;

/**
 Sets the timeout for file transfer. This value affects the methods that send a binary data including sending file messages, creating and updating channels.

 @param timeout Timeout in seconds. It must be greater than 0. Otherwise, the default value (60 seconds) will be set.
 @since 3.0.130
 */
+ (void)setFileTransferTimeout:(NSInteger)timeout;

@end

/**
 *  An object that adopts the `SBDConnectionDelegate` protocol is responsible for managing the connection statuses. This delegate includes three statuses: reconnection start, reconnection succession, and reconnection failure. The `SBDConnectionDelegate` can be added by [`addConnectionDelegate:identifier:`](../Classes/SBDMain.html#//api/name/addConnectionDelegate:identifier:) in `SBDMain`. Every `SBDConnectionDelegate` method which is added is going to manage the statues.
 *
 *  @warning If the object that adopts the `SBDConnectionDelegate` protocol is invalid, the delegate has to be removed by the identifier via [`removeConnectionDelegateForIdentifier:`](../Classes/SBDMain.html#//api/name/removeConnectionDelegateForIdentifier:) in `SBDMain`. If you miss this, it will cause the crash.
 */
@protocol SBDConnectionDelegate <NSObject>

@optional

/**
 *  Invoked when reconnection starts.
 */
- (void)didStartReconnection;

/**
 *  Invoked when reconnection is succeeded.
 */
- (void)didSucceedReconnection;

/**
 *  Invoked when reconnection is failed.
 */
- (void)didFailReconnection;

/**
 *  Invoked when reconnection is cancelled.
 */
- (void)didCancelReconnection;

@end

/**
 *  The `SBDMain` is the core class for SendBird. This class is singletone instance which is initialized by Application ID.
 *  This class provides the methods for overall. The methods include `SBDChannelDelegate` registration for receiving events are related to channels, `SBDConnectionDelegate` for managing the connection status, updating the current user's information, registration for APNS push notification and blocking other users.
 */
@interface SBDMain : NSObject

/**
 *  Shows the current log level.
 */
@property (atomic) SBDLogLevel logLevel;

/**
 *  Manages registered `SBDConnectionDelegate`.
 */
@property (nonatomic, strong, readonly, nullable) NSMapTable<NSString *, id<SBDConnectionDelegate>> *connectionDelegatesDictionary;

/**
 *  Manages registered `SBDChannelDelegate`.
 */
@property (nonatomic, strong, readonly, nullable) NSMapTable<NSString *, id<SBDChannelDelegate>> *channelDelegatesDictionary;

/**
 *  Manages registered `SBDUserEventlDelegate`.
 */
@property (nonatomic, strong, readonly, nullable) NSMapTable<NSString *, id<SBDUserEventDelegate>> *userEventDelegatesDictionary;

/**
 *  The completion handler of background session.
 */
@property (nonatomic, strong, nullable) SBDBackgroundSessionBlock backgroundSessionCompletionHandler;

/**
 *  The list of tasks in background.
 */
@property (strong, nonatomic, nonnull) NSMutableArray <SBDBackgroundSessionBlock> *backgroundTaskBlock;

/**
 *  The number of URLSessionDidFinishEventsForBackgroundURLSession.
 */
@property (atomic) int URLSessionDidFinishEventsForBackgroundURLSession;

/**
 *  Retrieves the SDK version.
 *
 *  @return The SDK version.
 */
+ (nonnull NSString *)getSDKVersion;

/**
 *  Retrieves the log level.
 *
 *  @return Log level.
 */
+ (SBDLogLevel)getLogLevel;

/**
 *  Gets the Application ID which was used for initialization.
 *
 *  @return The Application ID.
 */
+ (nullable NSString *)getApplicationId;

/**
 *  Sets the log level. The log level is defined by `SBDLogLevel`.
 *
 *  @param logLevel Log level.
 */
+ (void)setLogLevel:(SBDLogLevel)logLevel;

/**
 *  Gets the current debug mode.
 *
 *  @return If YES, this instance is debug mode.
 */
+ (BOOL)getDebugMode;

/**
 *  Gets a singleton instance of `SBDMain`.
 *
 *  @return a singleton instance for `SBDMain`.
 */
+ (nonnull SBDMain *)sharedInstance;

/**
 *  Gets initializing state.
 *
 *  @return If YES, `SBDMain` instance is initialized.
 */
+ (BOOL)isInitialized;

/**
 *  Initializes `SBDMain` singleton instance with SendBird Application ID. The Application ID is on SendBird dashboard. This method has to be run first in order to user SendBird.
 *
 *  @param applicationId The Applicatin ID of SendBird. It can be founded on SendBird Dashboard.
 *
 *  @return If YES, the applicationId is set.
 */
+ (BOOL)initWithApplicationId:(NSString * _Nonnull)applicationId;

/**
 *  Initialize `sharedContainerIdentifier` of NSURLSessionConfiguration to use background session.
 *  Important! If you use `App Extension` and use upload file message in extension, you MUST set thie field.
 *
 *  @param identifier   The identifier to set background session configuraion.
 */
+ (void)setSharedContainerIdentifier:(nonnull NSString *)identifier;

/**
 *  Performs a connection to SendBird with the user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute. `user` is the object to represent the current user.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId
        completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Performs a connection to SendBird with the user ID and the access token.
 *
 *  @param userId            The user ID.
 *  @param accessToken       The access token. If the user doesn't have access token, set nil.
 *  @param completionHandler The handler block to execute. `user` is the object to represent the current user.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId
              accessToken:(NSString * _Nullable)accessToken
        completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Performs a connection to SendBird with the user ID and the access token.
 *
 *  @param userId userId
 *  @param accessToken accessToken
 *  @param apiHost apiHost
 *  @param wsHost wsHost
 *  @param completionHandler completionHandler
 *  @see -connectWithUserId:accessToken:completionHandler:
 *  @warning *Important*: DON'T use this method. This method will be unavailable.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId
              accessToken:(NSString * _Nullable)accessToken
                  apiHost:(NSString * _Nullable)apiHost
                   wsHost:(NSString * _Nullable)wsHost
        completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the current user object. The object is valid when the connection succeeded.
 *
 *  @return The current user object.
 */
+ (nullable SBDUser *)getCurrentUser;

/**
 *  Gets the current user's latest connection millisecond time(UTC). If the connection state is not open, returns 0.
 *
 *  @return  latest connected millisecond time stamp.
 *
 *  @since 3.0.117
 */
+ (long long)getLastConnectedAt;

/**
 *  Disconnects from SendBird. If this method is invoked, the current user will be invalidated.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)disconnectWithCompletionHandler:(nullable void (^)(void))completionHandler;

/**
 *  Adds the `SBDConnectionDelegate`.
 *
 *  @param delegate   `SBDConnectionDelegate` delegate.
 *  @param identifier The identifier for the delegate.
 */
+ (void)addConnectionDelegate:(id<SBDConnectionDelegate> _Nonnull)delegate
                   identifier:(NSString * _Nonnull)identifier;

/**
 *  Removes the `SBDConnectionDelegate` by identifier.
 *
 *  @param identifier The identifier for the delegate to be removed.
 */
+ (void)removeConnectionDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 *  Gets the delegate for connection by indentifer.
 *
 *  @param identifier The identifier for delegate.
 *
 *  @return `SBDConnectionDelegate` delegate.
 */
+ (nullable id<SBDConnectionDelegate>)connectionDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 Removes all connection delegates;
 */
+ (void)removeAllConnectionDelegates;

/**
 *  Adds the `SBDChannelDelegate`.
 *
 *  @param delegate   `SBDChannelDelegate` delegate.
 *  @param identifier The identifier for delegate.
 */
+ (void)addChannelDelegate:(id<SBDChannelDelegate> _Nonnull)delegate
                identifier:(NSString * _Nonnull)identifier;

/**
 *  Removes the `SBDChannelDelegate` by identifier.
 *
 *  @param identifier The identifier for the delegate to be removed.
 */
+ (void)removeChannelDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 *  Gets the delegate for channel by indentifer.
 *
 *  @param identifier The identifier for delegate.
 *
 *  @return `SBDChannelDelegate` delegate.
 */
+ (nullable id<SBDChannelDelegate>)channelDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 Removes all channel delegates;
 */
+ (void)removeAllChannelDelegates;

/**
 *  Gets the WebSocket server connection state.
 *
 *  @return `SBDWebSocketConnectionState`
 *
 *  - `SBDWebSocketConnecting` - Connecting to the chat server
 *  - `SBDWebSocketOpen` - Connected to the chat server
 *  - `SBDWebSocketClosing` - Disconnecting from the chat server
 *  - `SBSWebSocketClosed` - Disconnected from the chat server
 */
+ (SBDWebSocketConnectionState)getConnectState;

/**
 Sets dispatch queue for every completion handler and delegate. Default queue is the main queue.
 
 @param queue Dispatch queue for every completion handler and delegate.
 */
+ (void)setCompletionHandlerDelegateQueue:(dispatch_queue_t _Nullable)queue;

/**
 Runs block in the dispatch queue that was set by `setCompletionHandlerDelegateQueue:`.
 
 @param block Block to run.
 */
+ (void)performCompletionHandlerDelegateQueueBlock:(dispatch_block_t _Nullable)block;

/**
 *  Creates `SBDUserListQuery` instance for getting a list of all users of this application.
 *
 *  @return `SBDUserListQuery` instance.
 *  @deprecated in 3.0.120. Use `createApplicationUserListQuery`.
 */
+ (nullable SBDUserListQuery *)createAllUserListQuery DEPRECATED_ATTRIBUTE;

/**
 *  Creates `SBDUserListQuery` instance for gettting a list of users of this application with user IDs.
 *
 *  @param userIds The user IDs to get user objects.
 *
 *  @return `SBDUserListQuery` instance.
 *  @deprecated in 3.0.120. Use `createApplicationUserListQuery` and `userIdsFilter` of `SBDApplicationUserListQuery`.
 */
+ (nullable SBDUserListQuery *)createUserListQueryWithUserIds:(NSArray<NSString *> * _Nonnull)userIds DEPRECATED_ATTRIBUTE;

/**
 Creates `SBDApplicationUserListQuery` instance for getting a list of all users of this application.

 @return `SBDApplicationUserListQuery` instance
 @since 3.0.120
 */
+ (nullable SBDApplicationUserListQuery *)createApplicationUserListQuery;

/**
 *  Creates `SBDBlockedUserListQuery` instance for getting a list of blocked users by the current user.
 *
 *  @return `SBDBlockedUserListQuery` instance.
 */
+ (nullable SBDBlockedUserListQuery *)createBlockedUserListQuery;

#pragma mark - For Current User
/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileUrl        New profile image url.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname
                               profileUrl:(NSString * _Nullable)profileUrl
                        completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileImage      New profile image data.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname
                             profileImage:(NSData * _Nullable)profileImage
                        completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileImage      New profile image data.
 *  @param progressHandler   The handler block to monitor progression. `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body data. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname
                             profileImage:(NSData * _Nullable)profileImage
                          progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler
                        completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileImageFilePath      New profile image file path.
 *  @param progressHandler   The handler block to monitor progression. `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body data. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname
                     profileImageFilePath:(NSString * _Nullable)profileImageFilePath
                          progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler
                        completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Gets the pending push token.
 *
 *  @return Returns the pending push token.
 */
+ (nullable NSData *)getPendingPushToken;

/**
 *  Registers the current device token to SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param unique            If YES, register device token after removing exsiting all device tokens of the current user. If NO, just add the device token.
 *  @param completionHandler The handler block to execute. `status` is the status for push token registration. It is defined in `SBDPushTokenRegistrationStatus`. `SBDPushTokenRegistrationStatusSuccess` represents the `devToken` is registered. `SBDPushTokenRegistrationStatusPending` represents the `devToken` is not registered because the connection is not established, so this method has to be invoked with `getPendingPushToken` method after the connection. The `devToken` is retrived by `getPendingPushToken`. `SBDPushTokenRegistrationStatusError` represents the push token registration is failed.
 */
+ (void)registerDevicePushToken:(NSData * _Nonnull)devToken
                         unique:(BOOL)unique
              completionHandler:(nullable void (^)(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error))completionHandler;

/**
 *  Registers the current device token to SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute. `status` is the status for push token registration. It is defined in `SBDPushTokenRegistrationStatus`. `SBDPushTokenRegistrationStatusSuccess` represents the `devToken` is registered. `SBDPushTokenRegistrationStatusPending` represents the `devToken` is not registered because the connection is not established, so this method has to be invoked with `getPendingPushToken` method after the connection. The `devToken` is retrived by `getPendingPushToken`. `SBDPushTokenRegistrationStatusError` represents the push token registration is failed.
 *
 *  @deprecated in 3.0.22
 */
+ (void)registerDevicePushToken:(NSData * _Nonnull)devToken
              completionHandler:(nullable void (^)(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Registers the current device token to SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute.
 *
 *  @deprecated in 3.0.9
 */
+ (void)registerPushToken:(NSData * _Nonnull)devToken
        completionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Unregisters the current device token from SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute.
 */
+ (void)unregisterPushToken:(NSData * _Nonnull)devToken
          completionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler;

/**
 *  Unregisters all device tokens for the current user from SendBird.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)unregisterAllPushTokenWithCompletionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler;

/**
 *  Blocks the specified user.
 *
 *  @param userId            The user ID to be blocked.
 *  @param completionHandler The handler block to execute. `blockedUser` is the blocked user by the current user.
 */
+ (void)blockUserId:(NSString * _Nonnull)userId
  completionHandler:(nullable void (^)(SBDUser * _Nullable blockedUser, SBDError * _Nullable error))completionHandler;

/**
 *  Blocks the specified user.
 *
 *  @param user              The user to be blocked.
 *  @param completionHandler The handler block to execute. `blockedUser` is the blocked user by the current user.
 */
+ (void)blockUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDUser * _Nullable blockedUser, SBDError * _Nullable error))completionHandler;

/**
 *  Unblocks the specified user.
 *
 *  @param userId            The user ID which was blocked.
 *  @param completionHandler The handler block to execute.
 */
+ (void)unblockUserId:(NSString * _Nonnull)userId
    completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unblocks the specified user.
 *
 *  @param user              The user who was blocked.
 *  @param completionHandler The handler block to execute.
 */
+ (void)unblockUser:(SBDUser * _Nonnull)user
  completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

#pragma mark - push preference
/**
 *  Sets Do-not-disturb.
 *  This method make snooze(or stop snooze) repeatedly.
 *  If you want to snooze specific period, use `setSnoozePeriodEnable:startTimestamp:endTimestamp:completionHandler:]`.
 *
 *  @param enable            Enables or not.
 *  @param startHour         Start hour.
 *  @param startMin          Start minute.
 *  @param endHour           End hour.
 *  @param endMin            End minute.
 *  @param timezone          Sets timezone.
 *  @param completionHandler The handler block to execute.
 */
+ (void)setDoNotDisturbWithEnable:(BOOL)enable
                        startHour:(int)startHour
                         startMin:(int)startMin
                          endHour:(int)endHour
                           endMin:(int)endMin
                         timezone:(NSString * _Nonnull)timezone
                completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Gets Do-not-disturb.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)getDoNotDisturbWithCompletionHandler:(nullable void (^)(BOOL isDoNotDisturbOn, int startHour, int startMin, int endHour, int endMin, NSString * _Nonnull timezone, SBDError * _Nullable error))completionHandler;

/**
 *  Makes a current user snooze/receive remote push notification in specific duration.
 *  If you use `[SBDMain setDoNotDisturbWithEnable:startHour:startMin:endHour:endMin:timezone:completionHandler:]` method as well, both methods are applied together.
 *  Keep in mind snoozing(or stop snoozing) is applied from this method *only once*, not repeatedly.
 *  If you want to snooze(do not disturb) repeatedly, use `[SBDMain setDoNotDisturbWithEnable:startHour:startMin:endHour:endMin:timezone:completionHandler:]`.
 *
 *  @param enabled  Enabled means snooze remote push notification in duration. If set to disabled, current user can receive remote push notification.
 *  @param startTimestamp Unix timestamp to start snooze.
 *  @param endTimestamp  Unix timestamp to end snooze.
 *  @param completionHandler  The handler block to execute when setting notification snoozed is complete.
 *
 *  @since 3.0.128
 */
+ (void)setSnoozePeriodEnable:(BOOL)enabled
               startTimestamp:(long long)startTimestamp
                 endTimestamp:(long long)endTimestamp
            completionHandler:(nullable SBDErrorHandler)completionHandler;

/**
 *  Requests whether the current user snooze remote push notification.
 *
 *  @param completionHandler  The handler block to execute when setting notification snoozed is complete.
 *
 *  @since 3.0.128
 */
+ (void)getSnoozePeriod:(nonnull SBDSnoozePeriodHandler)completionHandler;

/**
 *  Changes a setting that decides which push notification for the current user to receive in all of the group channel.
 *
 *  @param pushTriggerOption  The options to choose which push notification for the current user to receive.
 *  @param completionHandler  The handler block to execute when setting a push trigger option of the current user is completed.
 *
 *  @since 3.0.128
 */
+ (void)setPushTriggerOption:(SBDPushTriggerOption)pushTriggerOption
           completionHandler:(nullable SBDErrorHandler)completionHandler;

/**
 *  Requests a setting that decides which push notification for the current user to receive in all of the group channel.
 *
 *  @param completionHandler  The handler block to execute when getting a push trigger of the current user is completed.
 *
 *  @since 3.0.128
 */
+ (void)getPushTriggerOptionWithCompletionHandler:(nonnull SBDPushTriggerOptionHandler)completionHandler;

/**
 Sets push sound
 
 @param sound Push sound
 @param completionHandler The handler block to be executed after set push sound. This block has no return value and takes an argument that is an error made when there is something wrong to set it.
 */
+ (void)setPushSound:(NSString * _Nonnull)sound
   completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;


/**
 Gets push shound
 
 @param completionHandler The handler block to execute.
 */
+ (void)getPushSoundWithCompletionHandler:(nullable void (^)(NSString * _Nullable sound, SBDError * _Nullable error))completionHandler;


/**
 Sets a push template of the current user.
 
 @param name The name of push template. It can be `SBD_PUSH_TEMPLATE_DEFAULT` or `SBD_PUSH_TEMPLATE_ALTERNATIVE`.
 @param completionHandler The handler block to execute.
 */
+ (void)setPushTemplateWithName:(NSString * _Nonnull)name
              completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;


/**
 Gets a push template of the current user.
 
 @param completionHandler The handler block to execute. The `name` is the current user's push template.
 */
+ (void)getPushTemplateWithCompletionHandler:(nullable void (^)(NSString * _Nullable name, SBDError * _Nullable error))completionHandler;


/**
 Starts reconnection explictly. The `SBDConnectionDelegate` delegates will be invoked by the reconnection process.
 
 @return Returns YES if there is the data to be used for reconnection.
 */
+ (BOOL)reconnect;

/**
 Gets mime type of file.
 
 @param file File to get mime type.
 @return Returns mime type of the file.
 */
+ (nullable NSString *)getMimeType:(NSData * _Nullable)file;


/**
 Turns on or off the reconnection by network awareness.
 
 @param onOff If YES, the reconnection by network Awareness is turned.
 */
+ (void)setNetworkAwarenessReconnection:(BOOL)onOff;

/**
 Sets group channel invitation preference for auto acceptance.
 
 @param autoAccept If YES, the current user will accept the group channel invitation automatically.
 @param completionHandler The handler block to execute.
 */
+ (void)setChannelInvitationPreferenceAutoAccept:(BOOL)autoAccept
                               completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;


/**
 Gets group channel inviation preference for auto acceptance.
 
 @param completionHandler The handler block to execute.
 */
+ (void)getChannelInvitationPreferenceAutoAcceptWithCompletionHandler:(nullable void (^)(BOOL autoAccept, SBDError * _Nullable error))completionHandler;

#pragma mark - User Event
+ (void)addUserEventDelegate:(id<SBDUserEventDelegate> _Nonnull)delegate
                  identifier:(NSString * _Nonnull)identifier;

+ (void)removeUserEventDelegateForIdentifier:(NSString * _Nonnull)identifier;

+ (void)removeAllUserEventDelegates;

#pragma mark - Friend List
+ (nullable SBDFriendListQuery *)createFriendListQuery;

+ (void)addFriendsWithUserIds:(NSArray<NSString *> * _Nonnull)userIds
            completionHandler:(nullable void (^)(NSArray<SBDUser *> * _Nullable users, SBDError * _Nullable error))completionHandler;

+ (void)deleteFriendWithUserId:(NSString * _Nonnull)userId
             completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

+ (void)deleteFriendsWithUserIds:(NSArray<NSString *> * _Nonnull)userIds
               completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

+ (void)deleteFriendWithDiscovery:(NSString * _Nonnull)discoveryKey
                completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

+ (void)deleteFriendsWithDiscoveries:(NSArray<NSString *> * _Nonnull)discoveryKeys
                   completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

+ (void)uploadFriendDiscoveries:(NSDictionary<NSString *, NSString *> * _Nonnull)discoveryKeyAndNames
              completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

+ (void)getFriendChangeLogsByToken:(NSString * _Nullable)token
                 completionHandler:(nullable void (^)(NSArray<SBDUser *> * _Nullable updatedUsers, NSArray<NSString *> * _Nullable deletedUserIds, BOOL hasMore, NSString * _Nullable token, SBDError * _Nullable error))completionHandler;

#pragma mark - Channel List
/**
 *  Marks as read all group channels of the current user.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)markAsReadAllWithCompletionHandler:(nullable void (^)(SBDError *_Nullable error))completionHandler;

/**
 *  Marks as read some group channels of the current user.
 *
 *  @param channelUrls The array list with channel urls to be marked as read.
 *  @param completionHandler The handler block to execute.
 */
+ (void)markAsReadWithChannelUrls:(NSArray <NSString *> * _Nonnull)channelUrls
                completionHandler:(nullable void (^)(SBDError *_Nullable error))completionHandler;

#pragma mark - Group Channel
/**
 *  Gets the number of group channel with the filter.
 *
 *  @param memberStateFilter The member state of the current user in the channels that are counted.
 *  @param completionHandler The handler block to execute.
 *
 *  @since 3.0.116
 */
+ (void)getChannelCountWithMemberStateFilter:(SBDMemberStateFilter)memberStateFilter
                           completionHandler:(nonnull void (^)(NSUInteger groupChannelCount, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the total unread channel count of all group channels.
 *
 *  @param completionHandler The handler block to execute. The `unreadCount` is the total count of unread channels in all of group channel which the current is a member.
 *
 *  @since 3.0.116
 */
+ (void)getTotalUnreadChannelCountWithCompletionHandler:(nonnull void (^)(NSUInteger unreadCount, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the number of unread messages in group channels.
 *
 *  @param completionHandler The handler block to execute. The `unreadCount` is the total count of unread messages in all of group channel which the current is a member.
 *
 *  @since 3.0.116
 */
+ (void)getTotalUnreadMessageCountWithCompletionHandler:(nullable void (^)(NSUInteger unreadCount, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the total unread message count of the channels with filters of params.
 *
 *  @param params             The instance of parameters to filter.
 *  @param completionHandler  The handler block to be executed after getting total unread message count. This block has no return value and takes two argument, the one is the number of unread message and the other is error.
 *
 *  @since 3.0.116
 */
+ (void)getTotalUnreadMessageCountWithParams:(nonnull SBDGroupChannelTotalUnreadMessageCountParams *)params
                           completionHandler:(nonnull void (^)(NSUInteger unreadCount, SBDError * _Nullable error))completionHandler;

/**
 *  Get unread counts of message and invitation counts in super and non_super channels.
 *
 *  @param key  bitmask key composed of super/non_super unread message count, super/non_super invitation count.
 *  @param completionHandler  The handler block to be executed after getting unread item count. This block has no return value and takes two argument. the one is type of SBDUnreadItemCount that contains unsinged interger for count you requested. the other is an error made when there is something wrong to response.
 *
 *  @since 3.0.116
 */
+ (void)getUnreadItemCountWithKey:(SBDUnreadItemKey)key
                completionHandler:(nonnull void(^)(SBDUnreadItemCount * _Nullable count, SBDError * _Nullable error))completionHandler;

+ (NSInteger)getSubscribedTotalUnreadMessageCount;
+ (NSInteger)getSubscribedCustomTypeTotalUnreadMessageCount;
+ (NSInteger)getSubscribedCustomTypeUnreadMessageCountWithCustomType:(nonnull NSString *)customType;

#pragma mark - channel change logs
/**
 *  Requests updated channels and deleted channel URLs with token in the all my group channels.
 *
 *  @param token  The token used to get next pagination of changelogs.
 *  @param customTypes  The list of custom types to request. If not set, requests all of my group channels.
 *  @param completionHandler  The handler type of `SBDChannelChangeLogsHandler` block to execute. The `updatedChannels` is the channels that were updated. The `deletedChannelUrls` is the list of the deleted channel URLs. If there are more changelogs that are not returned yet, the `hasMore` is YES. The `token` can be used to get more changedlogs.
 *
 *  @since 3.0.123
 */
+ (void)getMyGroupChannelChangeLogsByToken:(nullable NSString *)token
                               customTypes:(nullable NSArray <NSString *> *)customTypes
                         completionHandler:(nonnull SBDChannelChangeLogsHandler)completionHandler;

/**
 *  Requests updated channels and deleted channel URLs by timestamp in the all my group channels.
 *
 *  @param timestamp  The number of milli-seconds(msec). Requests changelogs from that time. This value must not be negative.
 *  @param customTypes  The list of custom types to request. If not set, requests all of my group channels.
 *  @param completionHandler  The handler type of `SBDChannelChangeLogsHandler` block to execute. The `updatedChannels` is the channels that were updated. The `deletedChannelUrls` is the list of the deleted channel URLs. If there are more changelogs that are not returned yet, the `hasMore` is YES. The `token` can be used to get more changedlogs.
 *
 *  @since 3.0.123
 */
+ (void)getMyGroupChannelChangeLogsByTimestamp:(long long)timestamp
                                   customTypes:(nullable NSArray <NSString *> *)customTypes
                             completionHandler:(nonnull SBDChannelChangeLogsHandler)completionHandler;

@end

