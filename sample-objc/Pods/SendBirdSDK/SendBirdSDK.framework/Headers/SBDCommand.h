//
//  SBDCommand.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/22/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"
#import "SBDBaseChannel.h"
#import "SBDUserMessage.h"
#import "SBDGroupChannel.h"

/**
 *  SendBird internal use only.
 */
@interface SBDCommand : NSObject

/**
 *  Command.
 */
@property (strong, nonatomic, readonly, nullable) NSString *cmd;

/**
 *  Payload as string.
 */
@property (strong, nonatomic, readonly, nullable) NSString *payload;

/**
 *  Payload as dictionary.
 */
@property (strong, nonatomic, readonly, nullable) NSMutableDictionary *payloadDictionary;

/**
 *  Reques ID for ACK.
 */
@property (strong, nonatomic, readonly, nullable) NSString *requestId;

/**
 *  Encode to string for sending.
 *
 *  @return Encoded string of command.
 */
- (nullable NSString *)encode;

- (BOOL)isAckRequired;

- (BOOL)hasRequestId;

+ (nullable SBDCommand *)parseMessage:(NSString * _Nonnull)message;
+ (nullable SBDCommand *)buildEnterChannel:(SBDBaseChannel * _Nonnull)channel;
+ (nullable SBDCommand *)buildExitChannel:(SBDBaseChannel * _Nonnull)aUser;
+ (nullable SBDCommand *)buildUserMessageWithChannelUrl:(NSString * _Nonnull)channelUrl messageText:(NSString * _Nonnull)messageText data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType targetLanguages:(NSArray<NSString *> * _Nullable)targetLanguages;
+ (nullable SBDCommand *)buildUpdateUserMessageWithChannelUrl:(NSString * _Nonnull)channelUrl messageId:(long long)messageId messageText:(NSString * _Nullable)messageText data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType;
+ (nullable SBDCommand *)buildFileMessageWithFileUrl:(NSString * _Nonnull)fileUrl name:(NSString * _Nullable)name type:(NSString * _Nullable)type size:(NSUInteger)size data:(NSString * _Nullable)data requestId:(NSString * _Nullable)requestId channel:(SBDBaseChannel * _Nonnull)channel customType:(NSString * _Nullable)customType thumbnails:(NSArray * _Nullable)thumbnails DEPRECATED_ATTRIBUTE;
+ (nullable SBDCommand *)buildFileMessageWithFileUrl:(NSString * _Nonnull)fileUrl name:(NSString * _Nullable)name type:(NSString * _Nullable)type size:(NSUInteger)size data:(NSString * _Nullable)data requestId:(NSString * _Nullable)requestId channel:(SBDBaseChannel * _Nonnull)channel customType:(NSString * _Nullable)customType thumbnails:(NSArray * _Nullable)thumbnails requireAuth:(BOOL)requireAuth;
+ (nullable SBDCommand *)buildUpdateFileMessageWithChannelUrl:(NSString * _Nonnull)channelUrl messageId:(long long)messageId data:(NSString * _Nullable)data customType:(NSString * _Nullable)customType;
+ (nullable SBDCommand *)buildPing;
+ (nullable SBDCommand *)buildStartTyping:(SBDGroupChannel * _Nonnull)channel startAt:(long long)startAt;
+ (nullable SBDCommand *)buildEndTyping:(SBDGroupChannel * _Nonnull)channel endAt:(long long)endAt;
+ (SBDCommand * _Nullable)buildReadOfChannel:(SBDGroupChannel * _Nonnull)channel;

@end
