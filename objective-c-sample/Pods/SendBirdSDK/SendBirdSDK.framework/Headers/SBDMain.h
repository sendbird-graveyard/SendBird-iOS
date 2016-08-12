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

/**
 *  Delegates for connection. This delegates include three cases, reconnection start, reconnection succession, and reconnection failure.
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
 *  SBDMain is the core class for SendBird. This class is singletone instance which is initialized by Application ID. 
 */
@interface SBDMain : NSObject

/**
 *  Log level.
 */
@property (atomic) SBDLogLevel logLevel;

/**
 *  Connection delegates.
 */
@property (nonatomic, strong, readonly, nullable) NSMutableDictionary<NSString *, NSValue *> *connectionDelegatesDictionary;

/**
 *  Channel delegates.
 */
@property (nonatomic, strong, readonly, nullable) NSMutableDictionary<NSString *, NSValue *> *channelDelegatesDictionary;

/**
 *  Initialize object.
 *
 *  @return SBDMain object.
 */
- (nullable instancetype)init;

/**
 *  Get the SDK version.
 *
 *  @return The SDK version.
 */
+ (nonnull NSString *)getSDKVersion;

/**
 *  Get log level.
 *
 *  @return Log level.
 */
+ (SBDLogLevel)getLogLevel;

/**
 *  Get the Application ID.
 *
 *  @return The Application ID.
 */
+ (nullable NSString *)getApplicationId;

/**
 *  Set log level.
 *
 *  @param logLevel Log level.
 */
+ (void)setLogLevel:(SBDLogLevel)logLevel;

/**
 *  Get debug mode.
 *
 *  @return If YES, this instance is debug mode.
 */
+ (BOOL)getDebugMode;

/**
 *  Get a singleton instance of SBDMain.
 *
 *  @return a singleton instance for SBDMain
 */
+ (nonnull SBDMain *)sharedInstance;

/**
 *  Get initializing state.
 *
 *  @return If YES, instance is initialized.
 */
+ (BOOL)isInitialized;

/**
 *  Initialize SBDMain singleton instance with SendBird Application ID.
 *
 *  @param applicationId The Applicatin ID of SendBird. It can be founded on SendBird Dashboard.
 */
+ (void)initWithApplicationId:(NSString * _Nonnull)applicationId;

/**
 *  Print log by level.
 *
 *  @param logLevel  Log level.
 *  @param format Formatted log message.
 *  @param ... A comma-separated list of arguments to substitute into format.
 */
+ (void)logWithLevel:(SBDLogLevel)logLevel format:(NSString * _Nonnull)format, ...;

/**
 *  Perform a connection to SendBird with the user ID.
 *
 *  @param userId            The user ID.
 *  @param completionHandler The handler block to execute.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Perform a connection to SendBird with the user ID and the access token.
 *
 *  @param userId            The user ID.
 *  @param accessToken       The access token. If the user doesn't access token, set nil. 
 *  @param completionHandler The handler block to execute.
 */
+ (void)connectWithUserId:(NSString * _Nonnull)userId accessToken:(NSString * _Nullable)accessToken completionHandler:(nullable void (^)(SBDUser * _Nullable user, SBDError * _Nullable error))completionHandler;

/**
 *  Get the current user object.
 *
 *  @return The current user object.
 */
+ (nullable SBDUser *)getCurrentUser;

/**
 *  Clear the current user object. Internal only.
 *  TODO: Remove this method.
 */
+ (void)clearCurrentUser;

/**
 *  Disconnect.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)disconnectWithCompletionHandler:(nullable void (^)())completionHandler;

/**
 *  Add delegate for connection management. This method has to be invoked by SBDMain instance.
 *
 *  @param delegate   SBDConnectionDelegate delegate.
 *  @param identifier The identifier for delegate.
 */
+ (void)addConnectionDelegate:(id<SBDConnectionDelegate> _Nonnull)delegate identifier:(NSString * _Nonnull)identifier;

/**
 *  Remove delegate by identifier. This method has to be invoked by SBDMain instance.
 *
 *  @param identifier The identifier for delegate.
 */
+ (void)removeConnectionDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 *  Add delegate for channel. This method has to be invoked by SBDMain instance.
 *
 *  @param delegate   SBDChannelDelegate delegate.
 *  @param identifier The identifier for delegate.
 */
+ (void)addChannelDelegate:(id<SBDChannelDelegate> _Nonnull)delegate identifier:(NSString * _Nonnull)identifier;

/**
 *  Remove delegate by identifier. This method has to be invoked by SBDMain instance.
 *
 *  @param identifier The identifier for delegate.
 */
+ (void)removeChannelDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 *  Get delegate by indentifer. This method has to be invoked by SBDMain instance.
 *
 *  @param identifier The identifier for delegate.
 *
 *  @return SBDChannelDelegate delegate.
 */
+ (nullable id<SBDChannelDelegate>)channelDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 *  Get the WebSocket server connection state.
 *
 *  @return SBDWebSocketConnectionState
 *
 *  - `SBDWebSocketConnecting` - Connecting to the chat server
 *  - `SBDWebSocketOpen` - Connected to the chat server
 *  - `SBDWebSocketClosing` - Disconnecting from the chat server
 *  - `SBSWebSocketClosed` - Disconnected from the chat server
 */
+ (SBDWebSocketConnectionState)getConnectState;

/**
 *  SendBird internal use only.
 *
 *  @param command SBDCommand object.
 *  @param completionHandler The handler block to execute.
 */
- (void)_sendCommand:(SBDCommand * _Nonnull)command completionHandler:(nullable void (^)(SBDCommand * _Nullable command, SBDError * _Nullable error))completionHandler;

/**
 *  Create SBDUserListQuery instance for getting user list of this application.
 *
 *  @return SBDUserListQuery instance.
 */
+ (nullable SBDUserListQuery *)createAllUserListQuery;

/**
 *  Create a query object for blocked user list.
 *
 *  @return SBDBlockedUserListQuery object.
 */
+ (nullable SBDUserListQuery *)createBlockedUserListQuery;

#pragma mark - For Current User
/**
 *  Update user information.
 *
 *  @param nickname          New nickname.
 *  @param profileUrl        New profile image url.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileUrl:(NSString * _Nullable)profileUrl completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Update user information.
 *
 *  @param nickname          New nickname.
 *  @param profileImage      New profile image data.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileImage:(NSData * _Nullable)profileImage completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Update user information.
 *
 *  @param nickname          New nickname.
 *  @param profileImage      New profile image data.
 *  @param progressHandler   The handler block to monitor progression.
 *  @param completionHandler The handler block to execute.
 */
+ (void)updateCurrentUserInfoWithNickname:(NSString * _Nullable)nickname profileImage:(NSData * _Nullable)profileImage progressHandler:(nullable void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progressHandler completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Register the current device token to SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute.
 */
+ (void)registerPushToken:(NSData * _Nonnull)devToken completionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler;

/**
 *  Unregister the current device token from SendBird.
 *
 *  @param devToken          Device token for APNS.
 *  @param completionHandler The handler block to execute.
 */
+ (void)unregisterPushToken:(NSData * _Nonnull)devToken completionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler;

/**
 *  Unregister the all device tokens for the current user from SendBird.
 *
 *  @param completionHandler The handler block to execute.
 */
+ (void)unregisterAllPushTokenWithCompletionHandler:(nullable void (^)(NSDictionary * _Nullable response, SBDError * _Nullable error))completionHandler;

/**
 *  Blocks the specified user.
 *
 *  @param userId            The user ID to be blocked.
 *  @param completionHandler The handler block to execute.
 */
+ (void)blockUserId:(NSString * _Nonnull)userId completionHandler:(nullable void (^)(SBDUser * _Nullable blockedUser, SBDError * _Nullable error))completionHandler;

/**
 *  Blocks the specified user.
 *
 *  @param user              The user to be blocked.
 *  @param completionHandler The handler block to execute.
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

@end
