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
 *  An object which retrieves the list of open channels.
 */
@interface SBDOpenChannelListQuery : NSObject

/**
 *  Search Keyword - If the value is nil or the length is 0, this will retrieve all channels
 */
@property (strong, nonatomic, nullable) NSString *query;

/**
 *  Set the number of channels per page (limit)
 */
@property (atomic) NSUInteger limit;

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
 *  Get the list of channels. If this method is repeatedly called, it will retrieve the following pages of the channel list.
 *
 *  @param completionHandler The handler block to execute.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDOpenChannel *> * _Nullable channels, SBDError *_Nullable error))completionHandler;

@end
