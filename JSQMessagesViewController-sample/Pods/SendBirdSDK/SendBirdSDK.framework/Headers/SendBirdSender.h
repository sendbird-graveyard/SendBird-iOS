//
//  SendBirdSender.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 6..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class used for sender.
 */
@interface SendBirdSender : NSObject

/**
 *  Integer number ID assigned to user for identification.
 */
@property long long senderId;

/**
 *  User name
 */
@property (retain) NSString *name;

/**
 *  Profile image URL
 */
@property (retain) NSString *imageUrl;

/**
 *  ID used for identification. Same as [`SendBirdUser guestID`](./SendBirdUser.html#//api/name/guestId)
 */
@property (retain) NSString *guestId;

/**
 *  Returns YES if the user is muted, otherwise returns NO
 */
@property BOOL isMuted;

- (id) initWithDic:(NSDictionary *)dic;

@end
