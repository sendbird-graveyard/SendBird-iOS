//
//  SBDUser.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/22/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDError.h"
#import "SBDTypes.h"

@class SBDBlockedUserListQuery;

/**
 * Represents a user.
 */
@interface SBDUser : NSObject

/**
 *  User ID.
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
 *  User connection status.
 */
@property (atomic, readonly) SBDUserConnectionStatus connectionStatus;

/**
 *  <#Description#>
 */
@property (atomic, readonly) long long lastSeenAt;

/**
 *  Device token for APNS. This value is valid in the current user only.
 */
@property (strong, nonatomic, nullable) NSString *devToken;

/**
 *  Initialize object.
 *
 *  @param dict Dictionary data.
 *
 *  @return SBDUser object.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

@end
