//
//  SendBirdChannelMetaDataQuery.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 3/11/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdClient.h"

@interface SendBirdChannelMetaDataQuery : NSObject

- (id) initWithClient:(SendBirdClient *)sendBirdClient channelUrl:(NSString *)chUrl;

/**
 *  Get meta data for channel
 *
 *  @param keys       Keys to get meta data
 *  @param onResult   Callback for result. `response` contains meta data.
 *  @param onError    Callback for error
 */
- (void) getMetaDataWithKeys:(NSArray<NSString *> *)keys resultBlock:(void (^)(NSDictionary *response))onResult endBlock:(void (^)(NSInteger code))onError;

/**
 *  Set meta data for channel
 *
 *  @param metadata   Meta data to be set
 *  @param onResult   Callback for result
 *  @param onError    Callback for error
 */
- (void) setMetaData:(NSDictionary *)metadata resultBlock:(void (^)(NSDictionary *response))onResult endBlock:(void (^)(NSInteger code))onError;

/**
 *  Delete meta data for channel
 *
 *  @param keys       Keys to delete meta data
 *  @param onResult   Callback for result. `response` contains deleted meta data.
 *  @param onError    Callback for error
 */
- (void) deleteMetaDataWithKeys:(NSArray<NSString *> *)keys resultBlock:(void (^)(NSDictionary *response))onResult endBlock:(void (^)(NSInteger code))onError;

@end
