//
//  SendBirdCommand.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 3..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdFileInfo.h"

@interface SendBirdCommand : NSObject

@property (retain) NSString *command;
@property (retain) NSString *payload;

- (id) initWithCommand:(NSString *)command andPayload:(NSString *)payload;
- (id) initWithCommand:(NSString *)command andDictionaryPayload:(NSDictionary *)payload;
- (void) decode:(NSString *)command;
- (NSDictionary *) getJson;
- (NSString *) encode;

+ (SendBirdCommand *)parse:(NSString *)data;
+ (SendBirdCommand *)bLoginWithUserKey:(NSString *)userKey;
+ (SendBirdCommand *)bJoinWithChannelId:(NSString *)channelId andLastMessageTs:(long long)lastMessageTs;
+ (SendBirdCommand *)bMessageWithChannelId:(long long)channelId andMessage:(NSString *)message andData:(NSString *)data tempId:(NSString *)tempId mentionedUserIds:(NSArray *)mentionedUserIds;
+ (SendBirdCommand *)bFileOfChannelWithChannelId:(long long)channelId andFileInfo:(SendBirdFileInfo *)fileInfo;
+ (SendBirdCommand *)bPing;
+ (SendBirdCommand *)bReadOfChannel:(long long)channelId andTime:(long long)time;
+ (SendBirdCommand *)bTypeStartOfChannel:(long long)channelId andTime:(long long)time;
+ (SendBirdCommand *)bTypeEndOfChannel:(long long)channelId andTime:(long long)time;

@end
