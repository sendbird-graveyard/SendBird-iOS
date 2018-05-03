//
//  SBDUser.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SBDError.h"
#import "SBDTypes.h"

@class SBDUser;

@protocol SBDUserEventDelegate <NSObject>

@optional

- (void)didDiscoverFriends:(NSArray<SBDUser *> * _Nullable)friends;

@end

/**
 *  The `SBDUser` class represents a user. The user is identified by the `userId`, so the `userId` has to be unique. The `userId`, `nickname` and `profileUrl` are valid in every `SBDUser` instance, however the `connectionStatus` and `lastSeenAt` is valid in `SBDUser` instance from `SBDUserListQuery`.
 */
@interface SBDUser : NSObject

/**
 *  User ID. This has to be unique.
 */
@property (strong, nonatomic, readonly, nonnull) NSString *userId;

/**
 *  User nickname.
 */
@property (strong, nonatomic, nullable) NSString *nickname;

/**
 *  Profile image url.
 */
@property (strong, nonatomic, nullable) NSString *profileUrl;

/**
 *  Original profile image url.
 */
@property (strong, nonatomic, nullable) NSString *originalProfileUrl;

/**
 *  User connection status. This is defined in `SBDUserConnectionStatus`.
 */
@property (atomic, readonly) SBDUserConnectionStatus connectionStatus;

/**
 *  The lastest time when the user became offline.
 */
@property (atomic, readonly) long long lastSeenAt;

/**
 Represents the user is activated. This property is changed by the [Platform API](https://docs.sendbird.com/platform#user_3_update_a_user)
 */
@property (atomic, readonly) BOOL isActive;

@property (strong, nullable) NSString *friendDiscoveryKey;

@property (strong, nullable) NSString *friendName;

/**
 *  Internal use only.
 *
 *  @param dict dict
 *  @warning *Important*: DON'T use this method. This method will be unavailable.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 Builds a user object from serialized data.
 
 @param data Serialized data.
 @return SBDUser object.
 */
+ (nullable instancetype)buildFromSerializedData:(NSData * _Nonnull)data;

/**
 Serializes message object.
 
 @return Serialized <span>data</span>.
 */
- (nullable NSData *)serialize;

#pragma mark - Meta Data
/**
 Meta data.
 */
@property (strong, nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *metaData;

/**
 *  Creates the meta <span>data</span> for the current user.
 *
 *  @param metaData          The meta <span>data</span> to be set.
 *  @param completionHandler The handler block to execute. `metaData` is the meta <span>data</span> which are set on SendBird server.
 */
- (void)createMetaData:(NSDictionary<NSString *, NSString *> * _Nonnull)metaData
     completionHandler:(nullable void (^)(NSDictionary<NSString *, NSString *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Updates the meta <span>data</span> for the current user.
 *
 *  @param metaData          The meta <span>data</span> to be updated.
 *  @param completionHandler The handler block to execute. `metaData` is the meta counters which are updated on SendBird server.
 */
- (void)updateMetaData:(NSDictionary<NSString *, NSString *> * _Nonnull)metaData
     completionHandler:(nullable void (^)(NSDictionary<NSString *, NSString *> * _Nullable metaData, SBDError * _Nullable error))completionHandler;

/**
 *  Deletes meta <span>data</span> with key for the current user.
 *
 *  @param key               The key to be deleted.
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteMetaDataWithKey:(NSString * _Nonnull)key
            completionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

/**
 *  Deletes all meta <span>data</span> for the current user.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)deleteAllMetaDataWithCompletionHandler:(nullable void (^)(SBDError * _Nullable error))completionHandler;

@end
