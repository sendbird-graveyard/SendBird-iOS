//
//  SBDSender.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/12/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUser.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `SBDSender` class represents a sender of a user message and a file message.
 @since 3.0.121
 */
@interface SBDSender : SBDUser

/**
 If YES, the current user blocked the sender.
 */
@property (atomic, readonly) BOOL isBlockedByMe;

/**
 Builds a sender object from serialized data.
 
 @param data Serialized data.
 @return SBDSender object.
 */
+ (nullable instancetype)buildFromSerializedData:(NSData * _Nonnull)data;

/**
 Serializes a sender object.
 
 @return Serialized <span>data</span>.
 */
- (nullable NSData *)serialize;

@end

NS_ASSUME_NONNULL_END
