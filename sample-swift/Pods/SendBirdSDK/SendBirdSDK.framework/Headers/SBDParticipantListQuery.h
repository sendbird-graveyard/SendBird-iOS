//
//  SBDParticipantListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUserListQuery.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `SBDParticipantListQuery` class is a query class for getting the list of participants in an open channel. This instance is created by `createParticipantListQuery` of `SBDOpenChannel`.
 
 @since 3.0.120
 */
@interface SBDParticipantListQuery : SBDUserListQuery

@end

NS_ASSUME_NONNULL_END
