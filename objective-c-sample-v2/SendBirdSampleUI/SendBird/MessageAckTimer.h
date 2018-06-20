//
//  MessageAckTimer.h
//  SendBird Sample UI
//
//  Created by Jed Gyeong on 6/19/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 An object that adopts the `MessageAckTimerDelegate` protocol is a helper to recognize message delivery.
 */
@protocol MessageAckTimerDelegate <NSObject>

@optional

/**
 Extracts a key to identify a timer from a data of a message. If this method isn't implemented, the data is used as a key.

 @param data The data of a message
 @return A key to identify a timer and a message.
 */
- (NSString *)extractAckKeyFromData:(NSString *)data;

@required

/**
 When the message is delivered within the timeout, this method will be invoked with the key.
 
 @param key A key to identify a timer and a message.
 */
- (void)messageDelivered:(NSString *)key;

/**
 When the message isn't delivered within the timeout, this method will be invoked with the key.

 @param key A key to identify a timer and a message.
 */
- (void)messageDeliveryFailed:(NSString *)key;

@end

/**
 This class manages a timer for the message delivery.
 */
@interface MessageAckTimer : NSObject

@property (weak, nonatomic) id<MessageAckTimerDelegate> delegate;

/**
 Initializes the instance with a timeout.

 @param timeout If a message isn't delivered within the timeout, the instance judges the message is lost. The unit is a second.
 @return
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

/**
 When the client app sends a message, this method has to be invoked to register a timer with the data of the message. The data will be used as a key to identify the timer. The `extractAckKeyFromData:` method of `MessageAckTimerDelegate` delegate extracts a key from the data. If the method isn't implemented, the data is the key itself.

 @param data The data of a message that has a key to identify a timer.
 */
- (void)registerAckTimer:(NSString *)data;

/**
 When the client app receives a message, this method has to be invoked to unregister the timer with data of the message. The data will be used as a key to identify the timer. The `extractAckKeyFromData:` method of `MessageAckTimerDelegate` delegate extracts a key from the data. If the method isn't implemented, the data is the key itself.

 @param data The data of a message that has a key to identify a timer.
 */
- (void)unregisterAckTimer:(NSString *)data;

@end
