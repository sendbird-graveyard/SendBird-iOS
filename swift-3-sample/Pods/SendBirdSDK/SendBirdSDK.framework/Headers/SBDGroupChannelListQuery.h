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
 *  Gets the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute. The `channels` is the array of `SBDGroupChannel` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
