//
//  SendBirdBlockedUserListQuery.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 11. 24..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@interface SendBirdBlockedUserListQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient;
- (BOOL) isLoading;

- (void) executeWithResultBlock:(void (^)(int unreadMessageCount))onResult errorBlock:(void (^)(NSInteger code))onError;

@end
