//
//  SendBirdChannelMetaCounterQuery.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 3/11/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@interface SendBirdChannelMetaCounterQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient channelUrl:(NSString *)chUrl;

/**
 *  Get meta counter for channel
 *
 *  @param keys       Keys to get meta counter
 *  @param onResult   Callback for result. `response` contains meta counter.
 *  @param onError    Callback for error
 */
- (void) getMetaCounterWithKeys:(NSArray<NSString *> *)keys resultBlock:(void (^)(NSDictionary *response))onResult endBlock:(void (^)(NSInteger code))onError;

/**
 *  Set meta counter for channel
 *
 *  @param metacounter   Meta counter to be set
 *  @param onResult   Callback for result
 *  @param onError    Callback for error
 */
- (void) setMetaCounter:(NSDictionary *)metacounter resultBlock:(void (^)(NSDictionary *response))onResult endBlock:(void (^)(NSInteger code))onError;

/**
 *  Delete meta counter for channel
 *
 *  @param keys       Keys to delete meta counter
 *  @param onResult   Callback for result. `response` contains meta counter.
 *  @param onError    Callback for error
 */
- (void) deleteMetaCounterWithKeys:(NSArray<NSString *> *)keys resultBlock:(void (^)(NSDictionary *response))onResult endBlock:(void (^)(NSInteger code))onError;

/**
 *  Increase meta counter for channel
 *
 *  @param key      Key to be increased
 *  @param amount   Amount to be increased
 *  @param onResult Callback for result. `response` contains meta counter.
 *  @param onError  Callback for error
 */
- (void) increaseMetaCounterWithKey:(NSString *)key andAmount:(NSNumber *)amount resultBlock:(void (^)(NSDictionary<NSString *, NSNumber *> *response))onResult  endBlock:(void (^)(NSInteger code))onError;

/**
 *  Increase meta counter for channel
 *
 *  @param data       Data to be increased
 *  @param onResult   Callback for result. `response` contains meta counter.
 *  @param onError    Callback for error
 */
- (void) increaseMetaCounterWithData:(NSDictionary<NSString *, NSNumber *> *)data resultBlock:(void (^)(NSDictionary<NSString *, NSNumber *> *response))onResult  endBlock:(void (^)(NSInteger code))onError;

/**
 *  Decrease meta counter for channel
 *
 *  @param key      Key to be decreased
 *  @param amount   Amount to be decreased
 *  @param onResult Callback for result. `response` contains meta counter.
 *  @param onError  Callback for error
 */
- (void) decreaseMetaCounterWithKey:(NSString *)key andAmount:(NSNumber *)amount resultBlock:(void (^)(NSDictionary<NSString *, NSNumber *> *response))onResult  endBlock:(void (^)(NSInteger code))onError;

/**
 *  Decrease meta counter for channel
 *
 *  @param data       Data to be decreased meta counter
 *  @param onResult   Callback for result. `response` contains meta counter.
 *  @param onError    Callback for error
 */
- (void) decreaseMetaCounterWithData:(NSDictionary<NSString *, NSNumber *> *)data resultBlock:(void (^)(NSDictionary<NSString *, NSNumber *> *response))onResult  endBlock:(void (^)(NSInteger code))onError;

@end
