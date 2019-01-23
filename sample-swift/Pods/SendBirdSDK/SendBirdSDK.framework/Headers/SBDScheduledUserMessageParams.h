//
//  SBDScheduledUserMessageParams.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 10/26/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "SBDUserMessageParams.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a schduled user message params.
 @since 3.0.119
 */
@interface SBDScheduledUserMessageParams : SBDUserMessageParams

/**
 The scheduled date to send a message. (YYYY-MM-DD hh:mm)
 */
@property (strong, nullable, readonly) NSString *scheduledDateTimeString;

/**
 The timezone for the scheduled  date to send a message.
 */
@property (strong, nullable, readonly) NSString *scheduledTimezone;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

/**
 Initializes this params instance with a text message and the date to send the message.

 @param message The text message to be sent.
 @param year Year (YYYY), e.g. 2018.
 @param month Month (1~12).
 @param day Day (1~31).
 @param hour Hour (0~23).
 @param min Minute (0~59).
 @param timezone The timezone.
 @return SBDScheduledUserMessageParams instance.
 */
- (nullable instancetype)initWithMessage:(nonnull NSString *)message
                                    year:(NSInteger)year
                                   month:(NSInteger)month
                                     day:(NSInteger)day
                                    hour:(NSInteger)hour
                                     min:(NSInteger)min
                                timezone:(nonnull NSString *)timezone;

/**
 Sets the specific time to send a message.

 @param year Year (YYYY), e.g. 2018.
 @param month Month (1~12).
 @param day Day (1~31).
 @param hour Hour (0~23).
 @param min Minute (0~59).
 @param timezone The timezone.
 @return If YES, the values are valid.
 */
- (BOOL)setScheduleWithYear:(NSInteger)year
                      month:(NSInteger)month
                        day:(NSInteger)day
                       hour:(NSInteger)hour
                        min:(NSInteger)min
                   timezone:(nonnull NSString *)timezone;

@end

NS_ASSUME_NONNULL_END
