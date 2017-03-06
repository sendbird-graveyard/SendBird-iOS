//
//  SBDUser.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDError.h"
#import "SBDTypes.h"

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
 *  User connection status. This is defined in `SBDUserConnectionStatus`.
 */
@property (atomic, readonly) SBDUserConnectionStatus connectionStatus;

/**
 *  The lastest time when the user became offline.
 */
@property (atomic, readonly) long long lastSeenAt;

/**
 *  Internal use only.
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

@end
