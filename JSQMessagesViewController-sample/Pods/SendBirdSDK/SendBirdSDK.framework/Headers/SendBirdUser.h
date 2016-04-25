//
//  SendBirdUser.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  User class. Either a new user is created or logged in using an existing user based on the parameters set using [`loginWithUserName:`](./SendBird.html#//api/name/loginWithUserName:), [`loginWithUserName:andUserImageUrl:`](./SendBird.html#//api/name/loginWithUserName:andUserImageUrl:), [`igawLoginWithUserId:`](/SendBird.html#//api/name/igawLoginWithUserId:), [`igawLoginWithUserName:`](./SendBird.html#//api/name/igawLoginWithUserName:), [`igawLoginWithUserName:andUserImageUrl:`](./SendBird.html#//api/name/igawLoginWithUserName:andUserImageUrl:), [`loginWithUserId:andUserName:`](./SendBird.html#//api/name/loginWithUserId:andUserName:) methods. [`guestId`](./SendBirdUser.html#//api/name/guestId) is used to identify unique users, so we recommending using [`guestId`](./SendBirdUser.html#//api/name/guestId) to map the app's users to SendBird users.
 */
@interface SendBirdUser : NSObject

/**
 *  Integer value ID asssigned to users
 */
@property long long userId;

/**
 *  User name
 */
@property (retain) NSString *name;

/**
 *  Profile iamge URL
 */
@property (retain) NSString *imageUrl;

/**
 *  Unique identifier assigned to users
 */
@property (retain) NSString *guestId;

/**
 *  Returns YES if the user is muted, otherwise returns NO
 */
@property BOOL isMuted;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *)dic;

@end
