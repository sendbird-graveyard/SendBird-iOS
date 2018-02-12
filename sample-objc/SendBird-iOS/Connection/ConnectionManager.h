//
//  ConnectionManager.h
//  SendBird-iOS
//
//  Created by gyuyoung Hwang on 2018. 2. 7..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const _Nonnull ConnectionManagerErrorDomainConnection;
FOUNDATION_EXTERN NSString *const _Nonnull ConnectionManagerErrorDomainUser;

@class SBDUser;

@protocol ConnectionManagerDelegate <NSObject>

- (void)didConnect:(BOOL)isReconnection;

@optional
- (void)didDisconnect;

@end

@interface ConnectionManager : NSObject

+ (nullable instancetype)sharedInstance;

+ (void)loginWithCompletionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler;

+ (void)loginWithUserId:(nonnull NSString *)userId nickname:(nonnull NSString *)nickname completionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler;

+ (void)logoutWithCompletionHandler:(nullable void(^)(void))completionHandler;

/**
 * Registers an observer to receive connection notifications.
 *
 * @param observer  The object to register for connection notifications.
 */
+ (void)addConnectionObserver:(nonnull id<ConnectionManagerDelegate>)observer;

/**
 * Unregisters an observer to receive connection notifications.
 *
 * @param observer The object to register for connection notifications.
 */
+ (void)removeConnectionObserver:(nonnull id<ConnectionManagerDelegate>)observer;

@end
