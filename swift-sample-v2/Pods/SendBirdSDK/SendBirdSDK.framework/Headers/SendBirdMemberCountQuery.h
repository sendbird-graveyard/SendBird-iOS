//
//  SendBirdMemberCountQuery.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 3/15/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@class SendBirdClient;

/**
 *  Class used to retrieve a number of users in the application. This class is not used directly, but instead [`queryMemberCount:`](./SendBird.html#//api/name/queryMemberCount:) of [`SendBird`](./SendBird.html) must be used to creat instances.
 */
@interface SendBirdMemberCountQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient channelUrl:(NSString *)url;

/**
 *  Get member counts.
 *
 *  @param onResult Callback for result. `memberCount` means a number of members in the channel. `onlineMemberCount` means a number of online members and `accumulatedMemberCount` means a number of accumulated members`.
 *  @param onError  Callback for error
 */
- (void) getWithResultBlock:(void (^)(int memberCount, int onlineMemberCount, int accumulatedMemberCount))onResult endBlock:(void (^)(NSInteger code))onError;

@end