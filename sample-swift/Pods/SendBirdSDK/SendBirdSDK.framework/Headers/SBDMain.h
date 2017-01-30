//
//  SBDMain.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"
#import "SBDBaseChannel.h"
#import "SBDGroupChannel.h"
#import "SBDOpenChannelListQuery.h"
#import "SBDGroupChannelListQuery.h"
#import "SBDTypes.h"
#import "SBDUserListQuery.h"
#import "SBDInternalTypes.h"

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

- (nullable instancetype)init;

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
 */
+ (void)initWithApplicationId:(NSString * _Nonnull)applicationId;

/**
 *  SendBird internal use only.
 */
+ (void)logWithLevel:(SBDLogLevel)logLevel format:(NSString * _Nonnull)format, ...;

/**
 *  Performs a connection to SendBird with the user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute. `user` is the object to represent the current user.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Performs a connection to SendBird with the user ID and the access token.
 *
 *  @param userId            The user ID.
 *  @param accessToken       The access token. If the user doesn't have access token, set nil.
 *  @param completionHandler The handler block to execute. `user` is the object to represent the current user.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId accessToken:(NSString * _Nullable)accessToken completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Gets the current user object. The object is valid when the connection succeeded.
 *
 *  @return The current user object.
 */
+ (nullable SBDUser *)getCurrentUser;

/**
 *  SendBird internal use only.
 */
+ (void)clearCurrentUser;

/**
 *  Disconnects from SendBird. If this method is invoked, the current user will be invalidated.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)disconnectWithCompletionHandler:(nullable void (^)())completionHandler;

/**
 *  Adds the `SBDConnectionDelegate`.
 *
 *  @param delegate   `SBDConnectionDelegate` delegate.
 *  @param identifier The identifier for the delegate.
 */
+ (void)addConnectionDelegate:(id<SBDConnectionDelegate> _Nonnull)delegate identifier:(NSString * _Nonnull)identifier;

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
+ (void)addChannelDelegate:(id<SBDChannelDelegate> _Nonnull)delegate identifier:(NSString * _Nonnull)identifier;

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
 *  Internal use only.
 */
- (void)_sendCommand:(SBDCommand * _Nonnull)command completionHandler:(nullable void (^)(SBDCommand * _Nullable command, SBDError * _Nullable error))completionHandler;

/**
 *  Creates `SBDUserListQuery` instance for getting a list of all users of this application.
 *
 *  @return `SBDUserListQuery` instance.
 */
+ (nullable SBDUserListQuery *)createAllUserListQuery;

/**
 *  Creates `SBDUserListQuery` instance for gettting a list of users of this application with user IDs.
 *
 *  @param userIds The user IDs to get user objects.
 *
 *  @return `SBDUserListQuery` instance.
 */
+ (nullable SBDUserListQuery *)createUserListQueryWithUserIds:(NSArray<NSString *> * _Nonnull)userIds;

/**
 *  Creates `SBDUserListQuery` instance for getting a list of blocked users by the current user.
 *
 *  @return `SBDUserListQuery` instance.
 */
+ (nullable SBDUserListQuery *)createBlockedUserListQuery;

#pragma mark - For Current User
/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileUrl        New profile image url.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileUrl:(NSString * _Nullable)profileUrl completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileImage      New profile image data.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileImage:(NSData * _Nullable)profileImage completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileImage      New profile image data.
 *  @param progressHandler   The handler block to monitor progression. `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body data. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileImage:(NSData * _Nullable)profileImage progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Updates the current user's information.
 *
 *  @param nickname          New nickname.
 *  @param profileImageFilePath      New profile image file path.
 *  @param progressHandler   The handler block to monitor progression. `bytesSent` is the number of bytes sent since the last time this method was called. `totalBytesSent` is the total number of bytes sent so far. `totalBytesExpectedToSend` is the expected length of the body data. These parameters are the same to the declaration of [`URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`](https://developer.apple.com/reference/foundation/nsurlsessiontaskdelegate/1408299-urlsession?language=objc).
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileImageFilePath:(NSString * _Nullable)profileImageFilePath progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

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
+ (void)registerDevicePushToken:(NSData * _Nonnull)devToken unique:(BOOL)unique completionHandler:(nullable void (^)(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error))completionHandler;

/**
 *  Registers the current device token to SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute. `status` is the status for push token registration. It is defined in `SBDPushTokenRegistrationStatus`. `SBDPushTokenRegistrationStatusSuccess` represents the `devToken` is registered. `SBDPushTokenRegistrationStatusPending` represents the `devToken` is not registered because the connection is not established, so this method has to be invoked with `getPendingPushToken` method after the connection. The `devToken` is retrived by `getPendingPushToken`. `SBDPushTokenRegistrationStatusError` represents the push token registration is failed. 
 *
 *  @deprecated in 3.0.22
 */
+ (void)registerDevicePushToken:(NSData * _Nonnull)devToken completionHandler:(nullable void (^)(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Registers the current device token to SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute.
 *
 *  @deprecated in 3.0.9
 */
+ (void)registerPushToken:(NSData * _Nonnull)devToken completionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler DEPRECATED_ATTRIBUTE;

/**
 *  Unregisters the current device token from SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute.
 */
+ (void)unregisterPushToken:(NSData * _Nonnull)devToken completionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler;

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
+ (void)blockUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDUser * _Nullable blockedUser, SBDError * _Nullable error))completionHandler;

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
+ (void)unblockUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Unblocks the specified user.
 *
 *  @param user              The user who was blocked.
 *  @param completionHandler The handler block to execute.
 */
+ (void)unblockUser:(SBDUser * _Nonnull)user completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Sets Do-not-disturb.
 *
 *  @param enable            Enables or not.
 *  @param startHour         Start hour.
 *  @param startMin          Start minute.
 *  @param endHour           End hour.
 *  @param endMin            End minute.
 *  @param timezone          Sets timezone.
 *  @param completionHandler The handler block to execute.
 */
+ (void)setDoNotDisturbWithEnable:(BOOL)enable startHour:(int)startHour startMin:(int)startMin endHour:(int)endHour endMin:(int)endMin timezone:(NSString * _Nonnull)timezone completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Gets Do-not-disturb.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)getDoNotDisturbWithCompletionHandler:(nullable void (^)(BOOL isDoNotDisturbOn, int startHour, int startMin, int endHour, int endMin, NSString * _Nonnull timezone, SBDError * _Nullable error))completionHandler;


/**
 Sets a push template of the current user.

 @param name The name of push template. It can be `SBD_PUSH_TEMPLATE_DEFAULT` or `SBD_PUSH_TEMPLATE_ALTERNATIVE`.
 @param completionHandler The handler block to execute.
 */
+ (void)setPushTemplateWithName:(NSString * _Nonnull)name completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;


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

@end
