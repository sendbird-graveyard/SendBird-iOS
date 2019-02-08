//
//  SBDGroupChannelTotalUnreadMessageCountParams.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 5. 15..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDTypes.h"

/**
 *  The `SBDGroupChannelTotalUnreadMessageCountParams` instance contains parameters for `[SBDGroupChannel getTotalUnreadMessageCountWithParams:completionHandler:]`.
 *  When you want to get total unread message count with filters, use this instance. Add what you want to filter with, and pass this instance of `SBDGroupChannel`.
 *
 *  For more information, see [Group Channel](https://docs.sendbird.com/ios#group_channel).
 */
@interface SBDGroupChannelTotalUnreadMessageCountParams : NSObject

/**
 *  The array filter of channel custom types.
 */
@property (strong, atomic, nullable) NSArray <NSString *> *channelCustomTypesFilter;

/**
 *  The enumerator filter of super channel.
 */
@property (atomic) SBDGroupChannelSuperChannelFilter superChannelFilter;

@end
