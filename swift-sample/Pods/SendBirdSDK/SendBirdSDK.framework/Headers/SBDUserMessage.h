//
//  SBDUserMessage.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDBaseMessage.h"
#import "SBDBaseChannel.h"

@class SBDCommand;
@class SBDBaseChannel;

/**
 * Object representing a user message.
 */
@interface SBDUserMessage : SBDBaseMessage

/**
 *  Message text.
 */
@property (strong, nonatomic, readonly, nullable) NSString *message;

/**
 *  Data of message.
 */
@property (strong, nonatomic, readonly, nullable) NSString *data;

/**
 *  Sender of the message.
 */
@property (strong, nonatomic, readonly, nullable) SBDUser *sender;

/**
 *  Request ID for checking ACK.
 */
@property (strong, nonatomic, readonly, nullable) NSString *requestId;

- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

@end
