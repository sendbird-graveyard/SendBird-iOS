//
//  SBDBaseMessage.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/30/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"

/**
 * Base class for messages.
 */
@interface SBDBaseMessage : NSObject

/**
 *  Message ID.
 */
@property (atomic) long long messageId;

/**
 *  Channel URL which has this message.
 */
@property (strong, nonatomic, nullable) NSString *channelUrl;

/**
 *  Channel type of this message.
 */
@property (strong, nonatomic, nullable) NSString *channelType;

/**
 *  Message created time in millisecond.
 */
@property (atomic) long long createdAt;

/**
 *  Initialize object.
 *
 *  @param dict Dictionary data for user message.
 *
 *  @return SBDUserMessage object.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Build with dictionary.
 *
 *  @param dict The dictionary data.
 *
 *  @return SBDBaseMessage object.
 */
+ (nullable SBDBaseMessage *)buildWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Build with data.
 *
 *  @param data The data
 *
 *  @return SBDBaseMessage object.
 */
+ (nullable SBDBaseMessage *)buildWithData:(NSString * _Nonnull)data;

/**
 *  Check channel type is open channel or not.
 *
 *  @return Returns YES, when this is open channel.
 */
- (BOOL)isOpenChannel;

/**
 *  Check channel type is group channel or not.
 *
 *  @return Returns YES, when this is group channel.
 */
- (BOOL)isGroupChannel;

@end
