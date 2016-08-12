//
//  SendBirdMessagingUnreadCountQuery.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 7. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

/**
 *  Class used to retrieve the total unreal message count of the Messaging/Group messaging channel that the current user is in. This class is not used directly, but instead [`SendBird queryMessagingUnreadCount`](./SendBird.html#//api/name/queryMessagingUnreadCount) must be used to create instances.
 */
@interface SendBirdMessagingUnreadCountQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient;

- (BOOL) isLoading;

/**
 *  Get the total unreal message count of the Messaging/Group messaging channel that the current user is in
 *
 *  @param onResult Callback invoked upon success
 *  @param onError  Callback invoked upon failure
 */
- (void) executeWithResultBlock:(void (^)(int unreadMessageCount))onResult errorBlock:(void (^)(NSInteger code))onError;

@end
