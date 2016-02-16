//
//  SendBirdBroadcastMessage.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 10..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdMessageModel.h"

/**
 *  Class for broadcast messages. This class is comprised of message and additional data.
 */
@interface SendBirdBroadcastMessage : SendBirdMessageModel

/**
 *  Broadcast message
 */
@property (retain) NSString *message;

@property (retain) NSDictionary *jsonObj;

/**
 *  Additional data
 */
@property (retain) NSString *data;

- (id) initWithDic:(NSDictionary *)dic inPresent:(BOOL)present;

- (NSString *) toJson;

@end
