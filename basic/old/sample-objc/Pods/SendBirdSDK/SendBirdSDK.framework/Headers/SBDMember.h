//
//  SBDMember.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 7/6/17.
//  Copyright © 2017 SENDBIRD.COM. All rights reserved.
//

#import "SBDUser.h"
#import "SBDTypes.h"


/**
 The `SBDMember` class represents a member of a group channel. This class has a property to show the state for invitation.
 */
@interface SBDMember : SBDUser

/**
 The state for invitation. The values of the property are `invited` and `joined`. The `invited` means that the user doesn't accept the invitation yet and the `joined` means that the user accepted the invitation manually or automatically.
 */
@property (atomic) SBDMemberState state;

@property (atomic) BOOL isBlockedByMe;

@property (atomic) BOOL isBlockingMe;

/**
 *  DO NOT USE this initializer. You can only get an instance type of `SBDMember` from SDK.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 Builds a member object from serialized data.
 
 @param data Serialized data.
 @return SBDMember object.
 */
+ (nullable instancetype)buildFromSerializedData:(NSData * _Nonnull)data;

/**
 Serializes message object.
 
 @return Serialized <span>data</span>.
 */
- (nullable NSData *)serialize;

@end
