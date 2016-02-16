//
//  SendBirdMember.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 5. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class for channel members. The values are identical to [`SendBirdUser`](./SendBirdUser.html) class
 */
@interface SendBirdMember : NSObject

/**
 *  Member ID generated upon creation
 */
@property long long memberId;

/**
 *  Member name
 */
@property (retain) NSString *name;

/**
 *  Member's profile image URL
 */
@property (retain) NSString *imageUrl;

/**
 *  Unique ID to identify the member
 */
@property (retain) NSString *guestId;

@property (retain) NSDictionary *jsonObj;

- (id) initWithDic:(NSDictionary *) dic;
- (NSString *) toJson;

@end
