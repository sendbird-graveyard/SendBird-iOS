//
//  SendBirdMessageListQuery.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 6. 26..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class used to retrieve a number of previous or next messages based on a timestamp. This class is not used directly, but instead [`queryMessageListInChannel:`](./SendBird.html#//api/name/queryMessageListInChannel:) of [`SendBird`](./SendBird.html) must be used to creat instances.
 */
@interface SendBirdMessageListQuery : NSObject

- (id) initWithSendBirdClient:(SendBirdClient *)client andChannelUrl:(NSString *)channelUrl;

- (BOOL) isLoading;

/**
 *  Used to retrieve next messages based on a timestamp
 *
 *  @param messageTs Base timestamp (UTC)
 *  @param limit     Number of messages to retrieve
 *  @param onResult  Callback invoked upon successful retrieval. queryResult is an array of [`SendBirdMessageModel`](./SendBirdMessageModel.html)
 *  @param onError   Callback invoked upon failure
 */
- (void) nextWithMessageTs:(long long)messageTs andLimit:(int)limit resultBlock:(void (^)(NSMutableArray *queryResult))onResult endBlock:(void (^)(NSError *error))onError;

/**
 *  Used to retrieve previous messages based on a timestamp
 *
 *  @param messageTs Base timestamp (UTC)
 *  @param limit     Number of messages to retrieve
 *  @param onResult  Callback invoked upon successful retrieval. queryResult is an array of [`SendBirdMessageModel`](./SendBirdMessageModel.html)
 *  @param onError   Callback invoked upon failure
 */
- (void) prevWithMessageTs:(long long)messageTs andLimit:(int)limit resultBlock:(void (^)(NSMutableArray *queryResult))onResult endBlock:(void (^)(NSError *error))onError;

/**
 *  Used to retrieve previous and next messages based on a timestamp
 *
 *  @param messageTs Base timestamp (UTC)
 *  @param prevLimit Number of previous messages to retrieve
 *  @param nextLimit Number of next messages to retrieve
 *  @param onResult  Callback invoked upon successful retrieval. queryResult is an array of [`SendBirdMessageModel`](./SendBirdMessageModel.html)
 *  @param onError   Callback invoked upon failure
 */
- (void) loadWithMessageTs:(long long)messageTs prevLimit:(int)prevLimit andNextLimit:(int)nextLimit resultBlock:(void (^)(NSMutableArray *queryResult))onResult endBlock:(void (^)(NSError *error))onError;

/**
 *  Used to retrieve messages based on a two timestamps
 *
 *  @param messageStartTs Start timestamp (UTC)
 *  @param messageEndTs   End timestamp (UTC)
 *  @param onResult  Callback invoked upon successful retrieval. queryResult is an array of [`SendBirdMessageModel`](./SendBirdMessageModel.html)
 *  @param onError   Callback invoked upon failure
 */
- (void) loadWithMessageStartTs:(long long)messageStartTs messageEndTs:(long long)messageEndTs resultBlock:(void (^)(NSMutableArray *queryResult))onResult endBlock:(void (^)(NSError *error))onError;

@end
