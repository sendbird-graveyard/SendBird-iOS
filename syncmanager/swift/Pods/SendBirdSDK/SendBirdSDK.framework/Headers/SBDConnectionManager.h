//
//  SBDConnectionManager.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 6/26/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"
#import "SBDError.h"
#import "SBDTypes.h"


/**
 Network delegate.
 To add or remove this delegate, use `addNetworkDelegate:identifier:`, `removeNetworkDelegateForIdentifier:`, and `removeAllNetworkDelegates`.
 @since 3.0.109
 */
@protocol SBDNetworkDelegate <NSObject>

@required

/**
 A delegate method for when connection is reestablished.
 */
- (void)didReconnect;

@end

/**
 @since 3.0.113
 */
@protocol SBDAuthenticateDelegate <NSObject>

@required

/**
 A delegate method for the user authentication. Implements this method to get the user ID, the access token, the API host, and the WS host from the customer's side. The `completionHandler()` has to be invoked when the user authentication is completed. The `completionHandler()` will invoke `didFinishAuthenticationWithUser:error:` to return the user object and the error.

 @param completionHandler The completion handler to notify SendBird SDK of the completion of the user authentication.
 */
- (void)shouldHandleAuthInfoWithCompletionHandler:(void (^ _Nonnull)(NSString * _Nullable userId, NSString * _Nullable accessToken, NSString * _Nullable apiHost, NSString * _Nullable wsHost))completionHandler;

/**
 A delegate method for the completion of the user authentication. This delegate is invoked by the `completionHandler` of 'shouldHandleAuthInfoWithCompletionHandler:`.

 @param user The current user object.
 @param error The error object. If an error has occurred while connecting to SendBird, the `error` isn't nil.
 */
- (void)didFinishAuthenticationWithUser:(SBDUser * _Nullable)user error:(SBDError * _Nullable)error;

@end

@interface SBDConnectionManager : NSObject

/**
 Sets the `SBDAuthenticateDelegate`.

 @param delegate `SBDAuthenticateDelegate` delegate.
 @since 3.0.113
 */
+ (void)setAuthenticateDelegate:(id<SBDAuthenticateDelegate> _Nullable)delegate;

/**
 The authentication must be completed before authentication timeout. To set the timeout, use `setAuthenticationTimeout:` of `SBDOptions`.

 @since 3.0.113
 */
+ (void)authenticate;

/**
 Adds a network delegate. All added delegates will be notified when events occurs.

 @param delegate Delegate to be added.
 @param identifier ID of delegate to be added.
 @since 3.0.109
 */
+ (void)addNetworkDelegate:(id<SBDNetworkDelegate> _Nonnull)delegate
                identifier:(NSString * _Nonnull)identifier;

/**
 Removes a network delegate. The deleted delegate no longer be notified.

 @param identifier ID of delegate to be removed.
 @since 3.0.109
 */
+ (void)removeNetworkDelegateForIdentifier:(NSString * _Nonnull)identifier;

/**
 Removes all network delegates added by `addNetworkDelegate:identifier:`.
 @since 3.0.109
 */
+ (void)removeAllNetworkDelegates;

@end
