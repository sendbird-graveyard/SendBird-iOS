//
//  SBDPublicGroupChannelListQuery.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 1. 31..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDTypes.h"

@class SBDGroupChannel, SBDError;

/**
 *  The `SBDPublicGroupChannelListQuery` class is a query class for getting the list of public group channels.
 *  The instance of this class is created by [`createPublicGroupChannelListQuery`](../Classes/SBDGroupChannel.html#//api/name/createPublicGroupChannelListQuery) in `SBDGroupChannel` class.
 */
@interface SBDPublicGroupChannelListQuery : NSObject

/**
 *  Sets the number of channels per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  Shows if there is a next page
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  Shows if the query is loading.
 *  YES if the query is loading, otherwise returns NO.
 */
@property (atomic, readonly, getter=isLoading) BOOL loading;

/**
 *  If the value is YES, the channel list includes empty channel.
 *
 *  @param includeEmptyChannel  the flag to determine including an empty channel, or not.
 */
- (void)setIncludeEmptyChannel:(BOOL)includeEmptyChannel;

/**
 *  If the value is YES, the channel list includes their members.
 *
 *  @param includeMemberList    the flag to determine including channel's members.
 */
- (void)setIncludeMemberList:(BOOL)includeMemberList;

/**
 *  Sets the order of the list. The order is defined in `SBDPublicGroupChannelListOrder`.
 *  SBDPublicGroupChannelListOrderChronological by default.
 *
 *  @param order    the type to order a query result.
 */
- (void)setOrder:(SBDPublicGroupChannelListOrder)order;

/**
 *  Sets to filter super channel.
 *  SBDGroupChannelSuperChannelFilterAll by default.
 *
 *  @param superChannelFilter   the type to filter super group channels.
 */
- (void)setSuperChannelFilter:(SBDGroupChannelSuperChannelFilter)superChannelFilter;

/**
 *  Sets <code>SBDGroupChannel</code> URLs filter. <code>SBDGroupChannel</code> list containing only and exactly the passed <code>SBDGroupChannel</code> URLs will be returned. This does not cooperate with other filters.
 *
 *  @param publicMembershipFilter   the type to filter channels joined with me.
 */
- (void)setPublicMembershipFilter:(SBDPublicGroupChannelMembershipFilter)publicMembershipFilter;

/**
 *  Sets the custom types filter.
 *
 *  @param customTypes  the list to filter which have this custom type.
 */
- (void)setCustomTypesFilter:(nullable NSArray <NSString *> *)customTypes;

/**
 *  Sets to filter channels by custom type that starts with.
 *
 *  @param customTypeStartsWithFilter   a string to filter custom type that starts with this string.
 */
- (void)setCustomTypeStartsWithFilter:(nullable NSString *)customTypeStartsWithFilter;

/**
 *  Sets <code>SBDGroupChannel</code> URLs filter. <code>SBDGroupChannel</code> list containing only and exactly the passed <code>SBDGroupChannel</code> URLs will be returned. This does not cooperate with other filters.
 *
 *  @param channelUrls  the list to filter group channles that have this channel url.
 */
- (void)setChannelUrlsFilter:(nullable NSArray <NSString *> *)channelUrls;

/**
 *  Sets <code>SBDGroupChannel</code> names filter. <code>SBDGroupChannel</code> list containing only and exactly the passed <code>SBDGroupChannel</code> name will be returned. This does not cooperate with other filters.
 *
 *  @param channelNameContainsFilter    a string to filter channel name that contains this string.
 */
- (void)setChannelNameContainsFilter:(nullable NSString *)channelNameContainsFilter;

/**
 *  Gets the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute. The `channels` is the array of `SBDGroupChannel` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
