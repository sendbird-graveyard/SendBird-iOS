//
//  SendBirdOnlineMemberCountQuery.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 2/9/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@class SendBirdClient;

@interface SendBirdOnlineMemberCountQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient channelUrl:(NSString *)url;

- (void) getWithResultBlock:(void (^)(int onlineMemberCount))onResult endBlock:(void (^)(NSInteger code))onError;

@end
