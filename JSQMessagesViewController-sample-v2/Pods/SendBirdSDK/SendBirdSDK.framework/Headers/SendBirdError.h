//
//  SendBirdError.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 4. 20..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kErrReconnectFailed 8000
#define kErrNetwork 9000
#define kErrDataParsing 9010

#define kErrLogin 10000
#define kErrLoginAccessTokenInvalid 10010
#define kErrGetChannelInfo 11000
#define kErrFileUpload 12000
#define kErrLoadChannel 13000
#define kErrStartMessaging 14000
#define kErrJoinMessaging 14050
#define kErrEndMessaging 14100
#define kErrEndAllMessaging 14110
#define kErrInviteMessaging 14150
#define kErrHideMessaging 14200
#define kErrHideAllMessaging 14210
#define kErrMarkAsRead 15100
#define kErrMarkAsReadAll 15200
#define kErrLeaveChannel 16000

/**
 *  This class defines the error codes. For detailed error codes, please refer to [SendBird iOS SDK](https://sendbird.gitbooks.io/sendbird-ios-sdk/content/en/misc.html).
 */
@interface SendBirdError : NSObject

@end
