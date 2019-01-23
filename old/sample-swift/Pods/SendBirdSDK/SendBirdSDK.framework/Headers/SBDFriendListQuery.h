//
//  SBDFriendListQuery.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 12/27/17.
//  Copyright © 2017 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"
#import "SBDTypes.h"

@interface SBDFriendListQuery : NSObject

/**
 *  Sets the number of friends per page.
 */
@property (atomic) NSUInteger limit;

/**
 *  Shows if there is a next page
 */
@property (atomic, readonly) BOOL hasNext;

/**
 *  Gets the list of friends. If this method is repeatedly called, it will retrieve the following pages of the friend list.
 *
 *  @param completionHandler The handler block to execute. The `users` is the array of `SBDUser` instances.
 */
- (void)loadNextPageWithCompletionHandler:(nullable void (^)(NSArray<SBDUser *> * _Nullable users, SBDError *_Nullable error))completionHandler;

@end
