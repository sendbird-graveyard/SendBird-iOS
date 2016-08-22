//
//  SBDAdminMessage.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/23/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDBaseMessage.h"

/**
 * Object representing an admin message.
 */
@interface SBDAdminMessage : SBDBaseMessage

/**
 *  Message text.
 */
@property (strong, nonatomic, readonly, nullable) NSString *message;

/**
 *  Data of message.
 */
@property (strong, nonatomic, readonly, nullable) NSString *data;

- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

@end
