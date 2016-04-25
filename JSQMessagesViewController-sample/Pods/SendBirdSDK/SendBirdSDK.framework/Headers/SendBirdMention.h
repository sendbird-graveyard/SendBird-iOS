//
//  SendBirdMention.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 7. 30..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdSender.h"

/**
 *  Class used for user memtions. This class is returned as an object when mentionUpdated callback is invoked from [`registerNotificationHandlerMessagingChannelUpdatedBlock:mentionUpdatedBlock:`](./SendBird.html#//api/name/registerNotificationHandlerMessagingChannelUpdatedBlock:mentionUpdatedBlock:) of [`SendBird`](./SendBird.html)
 */
@interface SendBirdMention : NSObject

/**
 *  Channel URL where the user was mentioned
 */
@property (retain) NSString *channelUrl;

/**
 *  Type of the channel the user was mentioned in
 */
@property (retain) NSString *channelType;

/**
 *  Message sent during the mention
 */
@property (retain) NSString *message;

/**
 *  The sender who mentioned the user
 */
@property (retain) SendBirdSender *sender;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *) dic;

- (NSString *) toJson;

/**
 *  User name of the sender
 *
 *  @return User name
 */
- (NSString *) getSenderName;

/**
 *  Profile image URL of the sender
 *
 *  @return Profile image URL
 */
- (NSString *) getSenderImageUrl;

@end
