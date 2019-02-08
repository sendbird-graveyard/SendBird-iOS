//
//  SBDBannedUserListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUserListQuery.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `SBDBannedUserListQuery` class is a query class for getting the list of banned users in a specific channel. This instance is created by `createBannedUserListQuery` of `SBDGropuChannel` and `SBDOpenChannel`.
 
 @since 3.0.120
 */
@interface SBDBannedUserListQuery : SBDUserListQuery

@end

NS_ASSUME_NONNULL_END
