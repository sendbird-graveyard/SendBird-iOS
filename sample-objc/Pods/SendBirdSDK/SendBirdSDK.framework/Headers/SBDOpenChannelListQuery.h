//
//  SBDOpenChannelListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/25/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import "SBDOpenChannel.h"

@class SBDOpenChannel;

/**
 *  The `SBDOpenChannelListQuery` class is a query class for getting the list of open channels. The instance of this class is created by [`createOpenChannelListQuery`](../Classes/SBDOpenChannel.html#//api/name/createOpenChannelListQuery) in `SBDOpenChannel` class.
 */
@interface SBDOpenChannelListQuery : NSObject

/**
 *  Sets the number of channels per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  Shows if there is a next page.
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  Sets the keyword to search channel url.
 *
 *  @deprecated in 3.0.64. Use `setChannelUrlFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSString *urlKeyword
DEPRECATED_ATTRIBUTE;

/**
 *  Sets the keyword to search channel name.
 *
 *  @deprecated in 3.0.64. Use `setChannelNameFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSString *nameKeyword
DEPRECATED_ATTRIBUTE;

/**
 *  Sets the custom type filter.
 *
 *  @deprecated in 3.0.64. Use `setCustomTypeFilter:` instead.
 */
@property (strong, nonatomic, nullable) NSString *customTypeFilter
DEPRECATED_ATTRIBUTE;

/**
 *  Shows if the query is loading.
 *
 *  @return Returns YES if the query is loading, otherwise returns NO.
 */
- (BOOL)isLoading;


/**
 Sets the channel URL filter.

 @param channelUrl The channel url to search.
 */
- (void)setChannelUrlFilter:(NSString * _Nullable)channelUrl;


/**
 Sets the channel name filter.

 @param channelName The channel name to search.
 */
- (void)setChannelNameFilter:(NSString * _Nullable)channelName;


/**
 Sets the custom type filter.

 @param customType The custom type to search.
 */
- (void)setCustomTypeFilter:(NSString * _Nullable)customType;

/**
 *  Gets the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute. The `channels` is the array of `SBDOpenChannel` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
