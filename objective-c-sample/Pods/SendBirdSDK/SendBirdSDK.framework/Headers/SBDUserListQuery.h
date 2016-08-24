//
//  SBDUserListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/26/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDUser.h"
#import "SBDTypes.h"
#import "SBDBaseChannel.h"

/**
 *  An object which retrieves the list of all users, blocked users.
 */
@interface SBDUserListQuery : NSObject

/**
 *  The channel object related to query. 
 */
@property (strong, readonly, nullable) SBDBaseChannel *channel;

/**
 *  Query type.
 */
@property (atomic, readonly) SBDUserListQueryType queryType;

/**
 *  Set the number of users per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  Shows if there is a next page
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  Initialize query object with query type.
 *
 *  @param queryType Query type. It includes all user list of the app(`SBDUserListQueryTypeAllUser`), blocked user list of the current user(`SBDUserListQueryTypeBlockedUsers`), participant list of the open channel(`SBDUserListQueryTypeOpenChannelParticipants`), muted user list of the channel(`SBDUserListQueryTypeOpenChannelMutedUsers`) and banned user list of the channel(`SBDUserListQueryTypeOpenChannelBannedUsers`).
 *  @param channel   The channel object related to query.
 *
 *  @return SBDUserListQuery object.
 */
- (nullable instancetype)initWithQueryType:(SBDUserListQueryType)queryType channel:(SBDBaseChannel * _Nullable)channel;

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;

/**
 *  Get the list of users. If this method is repeatedly called, it will retrieve the following pages of the user list.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDUser *> * _Nullable users, SBDError *_Nullable error))completionHandler;

@end
