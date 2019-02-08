//
//  SBDOperatorListQuery.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 4. 19..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBDUser, SBDError;

/**
 *  The `SBDOperatorListQuery` class is a query class for getting the list of operators in channel.
 *  The instance of this class is created by [`createOperatorListQuery`](../Classes/SBDBaseChannel.html#//api/name/createOperatorListQuery) in `SBDBaseChannel` class.
 */
@interface SBDOperatorListQuery : NSObject

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
 *  DO NOT USE this initializer. Get from `[{base_channel} createOperatorListQuery]` instead.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 *  Gets the list of operators. If this method is repeatedly called, it will retrieve the following pages of an operator list.
 *
 *  @param completionHandler    The handler block to be executed after loading list of operators.
 *                              This block has no return value and takes two argument,
 *                              one is array of users who are operator and the other is ans error made when there is something wrong to load operators.
 *  @since 3.0.94
 */
- (void)loadNextPageWithCompletionHandler:(nonnull void (^)(NSArray <SBDUser *> * _Nullable users, SBDError *_Nullable error))completionHandler;

@end
