//
//  SBDUserMessageParams.h
//  SendBirdSDK
//
//  Created by sendbird-young on 2018. 3. 5..
//  Copyright © 2018년 SENDBIRD.COM. All rights reserved.
//

#import "SBDBaseMessageParams.h"

/**
 *  The `SBDUserMessageParams` class is used to send a user message in `SBDBaseChannel`. This is a child class of `SBDBaseMessageParams`.
 */
@interface SBDUserMessageParams : SBDBaseMessageParams

/**
 *  Message text.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nonnull) NSString *message;

/**
 *  The target languages that the message will be translated into.
 *
 *  @since 3.0.90
 */
@property (copy, nonatomic, nullable) NSArray <NSString *> *targetLanguages;

/**
 *  Don't use this initializer.
 *  Initializes an instance of a user message params.
 *
 *  @see -initWithMessage:
 *  @return nil as this method is unavailable.
 *  @since 3.0.90
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop
    
/**
 *  Initializes an instance of a user message params with message.
 *
 *  @param message The message to text.
 *  @return An initialized user message params, used to send user message.
 *  @since 3.0.90
 */
- (nullable instancetype)initWithMessage:(nonnull NSString *)message
NS_DESIGNATED_INITIALIZER;

@end
