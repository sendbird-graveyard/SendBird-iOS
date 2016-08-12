//
//  SendBirdMessagingChannelUpdate.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 6. 17..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendBirdMessagingChannelUpdate : NSObject

@property NSDictionary *jsonObj;
@property long long channelId;
@property BOOL messageUpdate;

- (id) initWithDic:(NSDictionary *) dic;
- (NSString *) toJson;
- (BOOL) isMessageUpdate;

@end
