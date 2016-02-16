//
//  SendBirdChannel.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 2. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdMessageModel.h"

/**
 *  SendBird Channel Class - This class includes Channel ID, Number of members within the channel, Channel URL, Channel Topic, Cover image URL, Channel creation timestamp
 */
@interface SendBirdChannel : SendBirdMessageModel

/**
 *  Channel ID
 */
@property long long channelId;

/**
 *  Members count for the channel
 */
@property int memberCount;

/**
 *  Channel URL
 */
@property (retain) NSString *url;

/**
 *  Channel Topic
 */
@property (retain) NSString *name;

/**
 *  Cover image URL
 */
@property (retain) NSString *coverUrl;

/**
 *  Channel creation timestamp (UTC)
 */
@property long long createdAt;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *) dic;

/**
 *  Returns Channel URL without the Namespace. Channel URL is comprised of a unique Namespace along with the channel identifier string. Use this method to retrieve the identifier part of the URL without the Namespace.
 *
 *  @return Channel URL without the Namespace
 */
- (NSString *) getUrlWithoutAppPrefix;

- (NSString *) toJson;

@end
