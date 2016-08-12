//
//  SendBirdMessagingChannelListQuery.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 6. 26..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@class SendBirdClient;

/**
 *  Class used to retrieve the list of Messaging/Group messaging channels that the current user is in. This class is not used directly, but instead [`SendBird queryMessagingChannelList`](./SendBird.html#//api/name/queryMessagingChannelList) must be used. The class supports Pagination, by assigning [`setLimit:`](./SendBirdMessagingChannelListQuery.html#//api/name/setLimit:), then calling [`nextWithResultBlock:endBlock:`](./SendBirdMessagingChannelListQuery.html#//api/name/nextWithResultBlock:endBlock:) repeatedly to get next results. If there is no more page to be shown, [`hasNext`](./SendBirdMessagingChannelListQuery.html#//api/name/hasNext) value becomes NO.
 */
@interface SendBirdMessagingChannelListQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient;

- (BOOL) isLoading;

/**
 *  Set the number of channels per page (limit)
 *
 *  @param lmt Number of channels per page
 */
- (void) setLimit:(int) lmt;

/**
 *  Set NO to include messaging channels don't have new messages since the user joined.
 *  Default is YES.
 *
 *  @param nmsj flag to set for getting messaging channels.
 */
- (void) setNewMessageSinceJoinedOnly:(BOOL) nmsj;

/**
 *  Check if the channel has a new message since the user joined
 *
 *  @return Returns YES if the channel list only returns channels have new messages since the user joined
 */
- (BOOL) isNewMessageSinceJoinedOnly;

/**
 *  Stop retrieving the channel list
 */
- (void) cancel;

/**
 *  Check if there is more channels to retrieve
 *
 *  @return Returns YES if there is a next page, otherwise returns NO
 */
- (BOOL) hasNext;

/**
 *  Get the list of Messaging/Group messaging channels the current user is in
 *
 *  @param onResult Callback invoked upon success. queryResult is an array of [`SendBirdMessagingChannel`](./SendBirdMessagingChannel.html)
 *  @param onError  Callback invoked upon error
 */
- (void) nextWithResultBlock:(void (^)(NSMutableArray *queryResult))onResult endBlock:(void (^)(NSInteger code))onError;

@end
