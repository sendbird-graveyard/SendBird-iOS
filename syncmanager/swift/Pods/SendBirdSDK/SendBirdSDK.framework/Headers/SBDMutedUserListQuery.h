//
//  SBDMutedUserListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUserListQuery.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `SBDMutedUserListQuery` class is a query class for getting the list of muted users in a specific channel. This instance is created by `createMutedUserListQuery` of `SBDOpenChannel`.
 
 @since 3.0.120
 */
@interface SBDMutedUserListQuery : SBDUserListQuery

@end

NS_ASSUME_NONNULL_END
