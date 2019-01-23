//
//  SBDBlockedUserListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUserListQuery.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `SBDBlockedUserListQuery` class is a query class for getting the list of blocked users by the current user. This instance is created by `createBlockedUserListQuery` of `SBDMain`.
 @since 3.0.120
 */
@interface SBDBlockedUserListQuery : SBDUserListQuery

/**
 Sets the user IDs filter.
 */
@property (copy, nonatomic, nullable) NSArray <NSString *> *userIdsFilter;

@end

NS_ASSUME_NONNULL_END
