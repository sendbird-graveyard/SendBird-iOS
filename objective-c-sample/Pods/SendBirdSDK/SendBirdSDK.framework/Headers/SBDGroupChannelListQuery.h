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
 *  An object which retrieves the list of group channels.
 */
@interface SBDGroupChannelListQuery : NSObject

/**
 *  Set the number of channels per page (limit)
 */
@property (atomic) NSUInteger limit;

/**
 *  If the value is YES, the channel list includes empty channel.
 */
@property (atomic) BOOL includeEmptyChannel;

/**
 *  If the value is YES, the channel object of the list includes member lists.
 */
@property (atomic) BOOL includeMemberList;

/**
 *  Set the order of the list.
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

/**
 *  Initialize object.
 *
 *  @return SBDGroupChannelListQuery object.
 */
- (nullable instancetype)init;

/**
 *  Initialize object with user.
 *
 *  @param user The user who is a member of channels.
 *
 *  @return SBDGroupChannelListQuery object.
 */
- (nullable instancetype)initWithUser:(SBDUser * _Nonnull)user;

/**
 *  Get the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
