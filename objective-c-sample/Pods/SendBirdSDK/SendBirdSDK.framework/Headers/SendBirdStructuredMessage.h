//
//  SendBirdStructuredMessage.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 10. 14..
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdSender.h"
#import "SendBirdMessageModel.h"
//#import "SendBirdSDKUtils.h"

@interface SendBirdStructuredMessage : SendBirdMessageModel

@property (retain) NSString *message;
@property (retain) SendBirdSender *sender;
//@property BOOL isOpMessage;
//@property BOOL isGuestMessage;
@property (retain) NSString *data;
@property (retain) NSDictionary *jsonObj;
@property (retain) NSString *tempId;
@property (retain) NSDictionary *structuredMessage;

@property (retain) NSString *structuredMessageTitle;
@property (retain) NSString *structuredMessageDesc;
@property (retain) NSString *structuredMessageThumbUrl;
@property (retain) NSString *structuredMessageUrl;
@property (retain) NSString *structuredMessageName;
@property (retain) NSString *structuredMessageIconUrl;

- (id) initWithDic:(NSDictionary *)dic;
- (id) initWithDic:(NSDictionary *)dic inPresent:(BOOL)present;
- (BOOL) hasSameSender:(SendBirdStructuredMessage *)msg;
- (NSString *)getSenderName;
//- (void) mergeWith:(SendBirdMessage *)merge;
- (NSString *) toJson;

@end
