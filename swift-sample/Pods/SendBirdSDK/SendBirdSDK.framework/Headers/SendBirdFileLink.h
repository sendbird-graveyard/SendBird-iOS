//
//  SendBirdFileLink.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 2. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdFileInfo.h"
#import "SendBirdSender.h"
#import "SendBirdMessageModel.h"
#import "SendBirdBlockedUser.h"

/**
 *  Class for file being transfered through messaging. This class includes sender, file information, and message blocked status
 */
@interface SendBirdFileLink : SendBirdMessageModel

/**
 *  Message sender. Uses [`SendBirdSender`](./SendBirdSender.html) class
 */
@property (retain) SendBirdSender *sender;

/**
 *  File information. Uses [`SendBirdFileInfo`](./SendBirdFileInfo.html) class
 */
@property (retain) SendBirdFileInfo *fileInfo;

@property BOOL isOpMessage;

@property BOOL isGuestMessage;

@property (retain) NSDictionary *jsonObj;

/**
 *  Returns YES if sent by a blocked user, otherwise returns NO
 */
@property BOOL isBlocked;

/**
 *  Returns YES if the user is muted, otherwise returns NO
 */
@property BOOL isSoftMuted;

- (id) initWithDic:(NSDictionary *)dic inPresent:(BOOL)present;

/**
 *  Get the name of the sender
 *
 *  @return User name of the sender
 */
- (NSString *)getSenderName;

- (NSString *) toJson;

@end
