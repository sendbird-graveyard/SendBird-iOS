//
//  SendBirdBlockedUser.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 11. 4..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdMessageModel.h"

@interface SendBirdBlockedUser : SendBirdMessageModel

- (id) initWithDic:(NSDictionary *)dic;
- (NSString *) toJson;
- (BOOL) isMessageBlocked:(SendBirdMessageModel *)message;

@property (retain) NSDictionary *jsonObj;
@property (retain) NSDictionary *blockedUserList;

@end
