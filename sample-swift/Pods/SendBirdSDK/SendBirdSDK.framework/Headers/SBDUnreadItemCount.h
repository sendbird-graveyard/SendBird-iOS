//
//  SBDUnreadItemCount.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 6. 13..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `SBDUnreadItemCount` class represents counts of messages. The instance of this class is returned from completion handler in `getUnreadItemCountWithKey:completionHandler:]`.
 */
@interface SBDUnreadItemCount : NSObject

/**
 *  The count of unread message in all of group channels.
 *  When you requested with `SBDUnreadItemKeyGroupChannelUnreadMessageCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeyGroupChannelUnreadMessageCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.103
 */
@property (nonatomic, readonly) NSUInteger groupChannelUnreadMessageCount;

/**
 *  The count of unread message in all of non super group channel.
 *  When you requested with `SBDUnreadItemKeyNonSuperUnreadMessageCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeyNonSuperUnreadMessageCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.101
 */
@property (nonatomic, readonly) NSUInteger nonSuperUnreadMessageCount;

/**
 *  The count of unread message in all of non super group channel.
 *  When you requested with `SBDUnreadItemKeySuperUnreadMessageCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeySuperUnreadMessageCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.101
 */
@property (nonatomic, readonly) NSUInteger superUnreadMessageCount;


/**
 *  The count of unread mention in all of group channels.
 *  When you requested with `SBDUnreadItemKeyGroupChannelUnreadMentionCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeyGroupChannelUnreadMentionCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.103
 */
@property (nonatomic, readonly) NSUInteger groupChannelUnreadMentionCount;

/**
 *  The count of unread mention in all of non super group channel.
 *  When you requested with `SBDUnreadItemKeyNonSuperUnreadMentionCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeyNonSuperUnreadMentionCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.103
 */
@property (nonatomic, readonly) NSUInteger nonSuperUnreadMentionCount;

/**
 *  The count of unread mention in all of non super group channel.
 *  When you requested with `SBDUnreadItemKeySuperUnreadMentionCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeySuperUnreadMentionCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.103
 */
@property (nonatomic, readonly) NSUInteger superUnreadMentionCount;


/**
 *  The count of unread message in all of group channels.
 *  When you requested with `SBDUnreadItemKeySuperInvitationCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeySuperInvitationCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.103
 */
@property (nonatomic, readonly) NSUInteger groupChannelInvitationCount;

/**
 *  The count of unread message in all of non super group channel.
 *  When you requested with `SBDUnreadItemKeyNonSuperInvitationCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeyNonSuperInvitationCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.101
 */
@property (nonatomic, readonly) NSUInteger nonSuperInvitationCount;

/**
 *  The count of unread message in all of non super group channel.
 *  When you requested with `SBDUnreadItemKeySuperInvitationCount`, then you can get unsigned integer count. If you DID NOT REQUEST `SBDUnreadItemKeySuperInvitationCount`, this property will be NSNotFound.
 *  @see `[SBDGroupChannel getUnreadItemCountWithKey:completionHandler:]`
 *  @since 3.0.101
 */
@property (nonatomic, readonly) NSUInteger superInvitationCount;

/**
 *  Returns a Boolean value that indicates whether a count of a given key is present, not NSNotFound.
 *
 *  @param key  An key to look for a count in the instance.
 *  @return Boolean  YES if counts for key is present in the instance, otherwise NO.
 *
 *  @since 3.0.101
 */
- (BOOL)has:(SBDUnreadItemKey)key;

/**
 *  Returns count for a given key.
 *
 *  @param key  An key to get a count in the instance.
 *  @return NSUInteger  The unsinged integer of the count for a given key. If key is composed of multiple SBDUnreadItemKey, the return value is combined.
 *
 *  @since 3.0.101
 */
- (NSUInteger)unsignedIntegerForKey:(SBDUnreadItemKey)key;

@end

NS_ASSUME_NONNULL_END
