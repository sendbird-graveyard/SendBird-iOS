//
//  SBDFileMessage.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 6/29/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDBaseMessage.h"
#import "SBDBaseChannel.h"

@class SBDBaseChannel;

/**
 * Object representing a file.
 */
@interface SBDFileMessage : SBDBaseMessage

/**
 *  Sender of the message.
 */
@property (strong, nonatomic, readonly, nullable) SBDUser *sender;

/**
 *  The file URL.
 */
@property (strong, nonatomic, readonly, nonnull) NSString *url;

/**
 *  The name of file.
 */
@property (strong, nonatomic, readonly, nonnull) NSString *name;

/**
 *  The size of file.
 */
@property (atomic, readonly) NSUInteger size;

/**
 *  The type of file.
 */
@property (strong, nonatomic, readonly, nonnull) NSString *type;

/**
 *  The custom data for file.
 */
@property (strong, nonatomic, readonly, nonnull) NSString *data;

/**
 *  Request ID for ACK.
 */
@property (strong, nonatomic, readonly, nullable) NSString *requestId;

- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Build file message with the information which is releated to file.
 *
 *  @param url       The file URL.
 *  @param name      The name of file.
 *  @param size      The size of file.
 *  @param type      The type of file.
 *  @param data      The custom data for file.
 *  @param requestId Request ID for ACK.
 *  @param sender    Sender of the message.
 *  @param channel   The channel which the file message is sent.
 *
 *  @return File message object with request ID.
 */
+ (nullable NSMutableDictionary<NSString *, NSObject *> *)buildWithFileUrl:(NSString * _Nonnull)url name:(NSString * _Nullable)name size:(NSUInteger)size type:(NSString * _Nonnull)type data:(NSString * _Nullable)data requestId:(NSString * _Nullable)requestId sender:(SBDUser * _Nonnull)sender channel:(SBDBaseChannel * _Nonnull)channel;

@end
