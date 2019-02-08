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
 *  @deprecated in 3.0.64. Use `customTypesFilter` instead.
 */
@property (strong, nonatomic, nullable) NSString *customTypeFilter
DEPRECATED_ATTRIBUTE;

/**
 *  Sets the member state filter.
 */
@property (nonatomic) SBDMemberStateFilter memberStateFilter;

/**
 *  Sets <code>SBDGroupChannel</code> URLs filter. <code>SBDGroupChannel</code> list containing only and exactly the passed <code>SBDGroupChannel</code> URLs will be returned. This does not cooperate with other filters.
 */
@property (copy, nonatomic, nullable) NSArray<NSString *> *channelUrlsFilter;

/**
 *  Sets a filter to return only channels that contains the specified group channel name.
 *
 *  @deprecated in 3.0.64. Use `setChannelNameContainsFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSString *channelNameFilter
DEPRECATED_ATTRIBUTE;

/**
 *  Sets to filter super channel.
 *  SBDGroupChannelSuperChannelFilterAll by default.
 */
@property (nonatomic) SBDGroupChannelSuperChannelFilter superChannelFilter;

/**
 *  Sets to filter public channel.
 *  SBDGroupChannelSuperChannelFilterAll by default.
 */
@property (nonatomic) SBDGroupChannelPublicChannelFilter publicChannelFilter;

/**
 *  Sets to filter channels by custom type that starts with.
 *
 *  @see Combined with `setCustomTypeStartsWithFilter:`.
 */
@property (copy, nonatomic, nullable) NSString *customTypeStartsWithFilter;

/**
 * Sets the custom types filter. The custom types to search.
 *
 *  @see Combined with `setCustomTypesFilter:`.
 */
@property (copy, nonatomic, nullable) NSArray <NSString *> *customTypesFilter;

/**
 *  Sets the filter with nickname. The group channels which have the member that has nickname are returned by `loadNextPageWithCompletionHandler:`(LIKE search).
 *
 *  @see Combined with `setNicknameContainsFilter:`.
 */
@property (copy, nonatomic, nullable) NSString *nicknameContainsFilter;

/**
 *  Sets the filter with user IDs. The group channels which have the members that contain user IDs are returned by `loadNextPageWithCompletionHandler:`.
 *
 *  @see Use `setUserIdsIncludeFilter:queryType:` to set the property.
 */
@property (copy, nonatomic, readonly, nullable) NSArray <NSString *> *userIdsIncludeFilter;

/**
 *  Sets the filter with user IDs. The group channels which have the members that have user IDs are returned by `loadNextPageWithCompletionHandler:`. The channels have the `userIds` members only.
 *
 *  @see Combined with `setUserIdsExactFilter:`.
 */
@property (copy, nonatomic, nullable) NSArray <NSString *> *userIdsExactFilter;

/**
 * Sets a filter to return only channels that contains the specified group channel name.
 * The channel name to search. The query will return the channels include `channelName`.
 *
 *  @see Combined with `setChannelNameContainsFilter:`.
 */
@property (copy, nonatomic, nullable) NSString *channelNameContainsFilter;

/**
 Sets to filter channels by the unread messages. The default value is `SBDUnreadChannelFilterAll`.
 
 @since 3.0.113
 */
@property (nonatomic) SBDUnreadChannelFilter unreadChannelFilter;

/**
 Sets a key for ordering by value in the metadata. This is valid when the `order` is `SBDGroupChannelListOrderChannelMetaDataValueAlphabetical` only.
 @since 3.0.118
 */
@property (copy, nonatomic, nullable) NSString *metaDataOrderKeyFilter;

/**
 Sets to filter channels by the hidden state. The default value is `SBDChannelHiddenStateFilterUnhiddenOnly`.
 @since 3.0.122
 */
@property (atomic) SBDChannelHiddenStateFilter channelHiddenStateFilter;

/**
 *  DO NOT USE this initializer. Use `[SBDGroupChannel createMyGroupChannelListQuery]` instead.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;

/**
 *  Sets the filter with user IDs. The group channels which have the members that have user IDs are returned by `loadNextPageWithCompletionHandler:`.
 *
 *  @param userIds    User IDs to search.
 *  @param exactMatch If YES, the group channels which have the `userIds` only are returned. If NO, the group channels which contain the `userIds` are returned. 
 *
 *  @deprecated in 3.0.19
 */
- (void)setUserIdsFilter:(NSArray<NSString *> * _Nonnull)userIds
              exactMatch:(BOOL)exactMatch
DEPRECATED_ATTRIBUTE;

/**
 *  Sets the filter with user IDs. The group channels which have the members that contain user IDs are returned by `loadNextPageWithCompletionHandler:`.
 *
 *  @param userIds    User IDs to search.
 *  @param queryType Logical condition applied to filter. If you pass `SBDGroupChannelListQueryTypeAnd` to `queryType` and A, B to `userIds`, the channels whose members containing A and B will be returned. If `SBDGroupChannelListQueryTypeOr` is set, the members of the queried channels will be A or B.
 *
 *  @see `userIdsIncludeFilter`, `queryType`.
 */
- (void)setUserIdsIncludeFilter:(NSArray<NSString *>* _Nonnull)userIds
                      queryType:(SBDGroupChannelListQueryType)queryType;

/**
 Sets the custom type filter.

 @param customType The custom type to search.
 
 @deprecated in v3.0.79.
 */
- (void)setCustomTypeFilter:(NSString * _Nullable)customType
DEPRECATED_ATTRIBUTE;

/**
 *  Gets the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute. The `channels` is the array of `SBDGroupChannel` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
