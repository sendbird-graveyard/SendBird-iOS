//
//  SBDGroupChannelMemberListQuery.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 1. 29..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDTypes.h"

@class SBDMember, SBDError;

/**
 *  The `SBDGroupChannelMemberListQuery` class is a query class for getting the list member in group channels. 
 *  The instance of this class is created by [`createMemberListQuery`](../Classes/SBDGroupChannel.html#//api/name/createMemberListQuery) in `SBDGroupChannel` class.
 */
@interface SBDGroupChannelMemberListQuery : NSObject

/**
 *  Don't use this initializer. Use `createGroupChannelListQuery` of `SBDGroupChannel` instead.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 *  Sets the number of members per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  Shows if there is a next page
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  Sets a filter to query operators.
 *
 *  @param filter  The filter about members as operator.
 *
 *  @since 3.0.89
 */
- (void)setOperatorFilter:(SBDGroupChannelOperatorFilter)filter;

/**
 *  Sets a filter to query muted member list.
 *
 *  @param filter  The filter about muted/unmuted members.
 *
 *  @since 3.0.89
 */
- (void)setMutedMemberFilter:(SBDGroupChannelMutedMemberFilter)filter;

/**
 *  Gets the list of member in group channel. If this method is repeatedly called, it will retrieve the following pages of the member list.
 *
 *  @param completionHandler The handler block to execute. The `users` is the array of `SBDUser` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDMember *> * _Nullable users, SBDError *_Nullable error))completionHandler;

@end
