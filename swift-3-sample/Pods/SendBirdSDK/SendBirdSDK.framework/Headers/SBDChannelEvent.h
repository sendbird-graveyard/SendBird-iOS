//
//  SBDSystemEvent.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBDTypes.h"
#import "SBDInternalTypes.h"

/**
 * SendBird internal use only.
 */
@interface SBDChannelEvent : NSObject

/**
 *  Event data.
 */
@property (strong, nonatomic, readonly, nonnull) NSDictionary *data;

/**
 *  The Channel URL where the event is occured.
 */
@property (strong, nonatomic, readonly, nonnull) NSString *channelUrl;

/**
 *  The type of event.
 */
@property (atomic, readonly) SBDChannelEventCategory channelEventCategory;

@property (atomic) NSInteger participantCount;

- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

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
