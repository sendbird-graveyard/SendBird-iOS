//
//  SendBirdChannelListQuery.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 3. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@class SendBirdClient;

/**
 *  Class used for retrieving the Channel List from Open Chat. The class includes current page, next page, and number of channels per page used for Pagination. Can be used to retrieve search results based on keywords. Call [`nextWithResultBlock:endBlock:`](./SendBirdChannelListQuery.html#//api/name/nextWithResultBlock:endBlock:) after setting [`limit`](./SendBirdChannelListQuery.html#//api/name/limit) and [`query`](./SendBirdChannelListQuery.html#//api/name/query).
 */
@interface SendBirdChannelListQuery : NSObject<NSURLConnectionDataDelegate>

/**
 *  Search Keyword - If the value is nil or the length is 0,this will retrieve all channels
 */
@property (retain) NSString *query;

/**
 *  Current page
 */
@property int page;

/**
 *  Next page
 */
@property int nextPage;

/**
 *  Set the number of channels per page (limit)
 */
@property int limit;

- (id) initWithClient:(SendBirdClient *)sendBirdClient;

/**
 *  Shows if there is a next page
 *
 *  @return Returns YES if the next page exists, otherwise returns NO
 */
- (BOOL) hasNext;

- (BOOL) isLoading;

/**
 *  Get the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list. The retrieved list will be returned within onResult as queryResult, which contains of an array of [`SendBirdChannel`](./SendBirdChannel.html).
 *
 *  @param onResult Callback invoked upon retrieval of the channel list
 *  @param onError  Callbakck invoked upon error
 */
- (void) nextWithResultBlock:(void (^)(NSMutableArray *queryResult))onResult endBlock:(void (^)(NSError *error))onError;

- (SendBirdClient *) getClient;

@end
