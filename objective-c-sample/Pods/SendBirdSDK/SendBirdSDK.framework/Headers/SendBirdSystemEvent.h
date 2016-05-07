//
//  SendBirdSystemEvent.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 3/16/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdMessageModel.h"
#import "SendBirdSDKUtils.h"

typedef enum {
    SendBirdSystemEventCategoryUnknown = 0,
    SendBirdSystemEventCategoryChannelJoin = 10100,
    SendBirdSystemEventCategoryChannelLeave = 10101,
    SendBirdSystemEventCategoryUserChannelMute = 10201,
} SendBirdSystemEventCategory;

@interface SendBirdSystemEvent : NSObject

@property NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *)dic;
- (NSString *) toJson;
- (NSString *) getDataAsString:(NSString *)key;
- (int) getDataAsInt:(NSString *)key;
- (long long) getDataAsLongLong:(NSString *)key;
- (BOOL) getDataAsBoolean:(NSString *)key;
- (SendBirdSystemEventCategory) getCategory;
- (long long) getChannelId;
@end
