//
//  SendBirdAppUser.h
//  SendBirdSDK
//
//  Created by Jed Kyung on 1/12/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Application user class. Either a new user is created or logged in using an existing user based on the parameters set using [`loginWithUserName:`](./SendBird.html#//api/name/loginWithUserName:), [`loginWithUserName:andUserImageUrl:`](./SendBird.html#//api/name/loginWithUserName:andUserImageUrl:), [`igawLoginWithUserId:`](/SendBird.html#//api/name/igawLoginWithUserId:), [`igawLoginWithUserName:`](./SendBird.html#//api/name/igawLoginWithUserName:), [`igawLoginWithUserName:andUserImageUrl:`](./SendBird.html#//api/name/igawLoginWithUserName:andUserImageUrl:), [`loginWithUserId:andUserName:`](./SendBird.html#//api/name/loginWithUserId:andUserName:) methods. [`guestId`](./SendBirdAppUser.html#//api/name/guestId) is used to identify unique users, so we recommending using [`guestId`](./SendBirdAppUser.html#//api/name/guestId) to map the app's users to SendBird users.
 */
@interface SendBirdAppUser : NSObject

/**
 *  Integer value ID asssigned to users
 */
@property long long userId;

/**
 *  User name
 */
@property (retain) NSString *nickname;

/**
 *  Profile image URL
 */
@property (retain) NSString *picture;

/**
 *  Unique identifier assigned to users
 */
@property (retain) NSString *guestId;

/**
 *  On-line or off-line status of user
 */
@property BOOL isOnline;

/**
 *  The latest time of logging off
 */
@property long long lastSeenAt;

/**
 *  Returns YES if the user is muted, otherwise returns NO
 */
@property BOOL isMuted;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *)dic;

@end
