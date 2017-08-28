//
//  SBDGroupChannelListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/25/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDError.h"
#import "SBDTypes.h"
#import "SBDUser.h"

@class SBDGroupChannel;
@class SBDUser;

/**
 *  The `SBDGroupChannelListQuery` class is a query class for getting the list of group channels. The instance of this class is created by [`createMyGroupChannelListQuery`](../Classes/SBDGroupChannel.html#//api/name/createMyGroupChannelListQuery) in `SBDGroupChannel` class.
 */
@interface SBDGroupChannelListQuery : NSObject

/**
 *  Sets the number of channels per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  If the value is YES, the channel list includes empty channel.
 */
@property (atomic) BOOL includeEmptyChannel;

/**
 *  If the value is YES, the channel object of the list includes members list.
 */
@property (atomic) BOOL includeMemberList;

/**
 *  Sets the order of the list. The order is defined in `SBDGroupChannelListOrder`.
 */
@property (atomic) SBDGroupChannelListOrder order;

/**
 *  Shows if there is a next page
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  Sets query type for `includeMemberList`.
 */
@property (atomic) SBDGroupChannelListQueryType queryType;

/**
 *  Sets the custom type filter.
 *
 *  @deprecated in 3.0.64. Use `setCustomTypeFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSString *customTypeFilter DEPRECATED_ATTRIBUTE;

/**
 *  Sets the member state filter.
 *
 *  @deprecated in 3.0.64. Use `setMemberStateFilter:` instead.
 */
@property (nonatomic) SBDMemberStateFilter memberStateFilter DEPRECATED_ATTRIBUTE;

/**
 *  Sets <code>SBDGroupChannel</code> URLs filter. <code>SBDGroupChannel</code> list containing only and exactly the passed <code>SBDGroupChannel</code> URLs will be returned. This does not cooperate with other filters.
 *
 *  @deprecated in 3.0.64. Use `setChannelUrlsFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSArray<NSString *> *channelUrlsFilter DEPRECATED_ATTRIBUTE;

/**
 *  Sets a filter to return only channels that contains the specified group channel name.
 *
 *  @deprecated in 3.0.64. Use `setChannelNameContainsFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSString *channelNameFilter DEPRECATED_ATTRIBUTE;

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;

- (nullable instancetype)init;

/**
 *  Internal use only.
 */
- (nullable instancetype)initWithUser:(SBDUser * _Nonnull)user;

/**
 *  Sets the filter with nickname. The group channels which have the member that has nickname are returned by `loadNextPageWithCompletionHandler:`(LIKE search).
 *
 *  @param nickname Nickname to search.
 */
- (void)setNicknameContainsFilter:(NSString * _Nullable)nickname;

/**
 *  Sets the filter with user IDs. The group channels which have the members that have user IDs are returned by `loadNextPageWithCompletionHandler:`.
 *
 *  @param userIds    User IDs to search.
 *  @param exactMatch If YES, the group channels which have the `userIds` only are returned. If NO, the group channels which contain the `userIds` are returned. 
 *
 *  @deprecated in 3.0.19
 */
- (void)setUserIdsFilter:(NSArray<NSString *> * _Nonnull)userIds exactMatch:(BOOL)exactMatch DEPRECATED_ATTRIBUTE;

/**
 *  Sets the filter with user IDs. The group channels which have the members that contain user IDs are returned by `loadNextPageWithCompletionHandler:`.
 *
 *  @param userIds    User IDs to search.
 *  @param queryType Logical condition applied to filter. If you pass `SBDGroupChannelListQueryTypeAnd` to `queryType` and A, B to `userIds`, the channels whose members containing A and B will be returned. If `SBDGroupChannelListQueryTypeOr` is set, the members of the queried channels will be A or B.
 */
- (void)setUserIdsIncludeFilter:(NSArray<NSString *>* _Nonnull)userIds queryType:(SBDGroupChannelListQueryType)queryType;

/**
 *  Sets the filter with user IDs. The group channels which have the members that have user IDs are returned by `loadNextPageWithCompletionHandler:`. The channels have the `userIds` members only.
 *
 *  @param userIds    User IDs to search.
 */
- (void)setUserIdsExactFilter:(NSArray<NSString *>* _Nonnull)userIds;

/**
 Sets the custom type filter.

 @param customType The custom type to search.
 */
- (void)setCustomTypeFilter:(NSString * _Nullable)customType;


/**
 Sets the member state filter.

 @param memberStateFilter The member state to search.
 */
- (void)setMemberStateFilter:(SBDMemberStateFilter)memberStateFilter;


/**
 Sets <code>SBDGroupChannel</code> URLs filter. <code>SBDGroupChannel</code> list containing only and exactly the passed <code>SBDGroupChannel</code> URLs will be returned. This does not cooperate with other filters.

 @param channelUrls The channel urls to search.
 */
- (void)setChannelUrlsFilter:(NSArray<NSString *> * _Nullable)channelUrls;


/**
 Sets a filter to return only channels that contains the specified group channel name.

 @param channelName The channel name to search. The query will return the channels include `channelName`.
 */
- (void)setChannelNameContainsFilter:(NSString * _Nullable)channelName;

/**
 *  Gets the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute. The `channels` is the array of `SBDGroupChannel` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
