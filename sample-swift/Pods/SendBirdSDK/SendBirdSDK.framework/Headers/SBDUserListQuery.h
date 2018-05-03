//
//  SBDUserListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/26/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDUser.h"
#import "SBDTypes.h"
#import "SBDInternalTypes.h"
#import "SBDBaseChannel.h"

/**
 *  The `SBDUserListQuery` class is a query class for getting the list of all users, participants, blocked users, muted users and banned users. Each type of the query is created by the class or the instance that is related to it.
 *
 *  * The query for the all users is created by [`createAllUserListQuery`](../Classes/SBDMain.html#//api/name/createAllUserListQuery) of `SBDMain` class.
 *  * The query for the users of the specified user IDs is created by [`createUserListQueryWithUserIds:`](../Classes/SBDMain.html#//api/name/createUserListQueryWithUserIds:) of `SBDMain` class.
 *  * The query for the blocked users is created by [`createBlockedUserListQuery`](../Classes/SBDMain.html#//api/name/createBlockedUserListQuery) of `SBDMain` class.
 *  * The query for the participants in the specified open <span>channel</span> is created by [`createParticipantListQuery`](../Classes/SBDOpenChannel.html#//api/name/createParticipantListQuery) of the `SBDOpenChannel` instance.
 *  * The query for the muted users is created by [`createMutedUserListQuery`](../Classes/SBDOpenChannel.html#//api/name/createMutedUserListQuery) of the `SBDOpenChannel` instance.
 *  * The query for the banned users is created by [`createBannedUserListQuery`](../Classes/SBDOpenChannel.html#//api/name/createBannedUserListQuery) of the `SBDOpenChannel` instance.
 *
 */
@interface SBDUserListQuery : NSObject

/**
 *  The channel instance related to query.
 */
@property (strong, readonly, nullable) SBDBaseChannel *channel;

/**
 *  Query type. It is defined in `SBDUserListQueryType`.
 */
@property (atomic, readonly) SBDUserListQueryType queryType;

/**
 *  Sets the number of users per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  Shows if there is a next page
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  DO NOT USE this initializer. Use `[SBDMain createBlockedUserListQuery]` instead.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 Sets meta data filter.

 @param key The key of the meta data to use for filter.
 @param values The values of the meta data to use for filter.
 */
- (void)setMetaDataFilterWithKey:(NSString * _Nonnull)key
                          values:(NSArray<NSString *> * _Nonnull)values;

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;

/**
 *  Gets the list of users. If this method is repeatedly called, it will retrieve the following pages of the user list.
 *
 *  @param completionHandler The handler block to execute. The `users` is the array of `SBDUser` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDUser *> * _Nullable users, SBDError *_Nullable error))completionHandler;

@end
