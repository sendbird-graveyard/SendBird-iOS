//
//  SendBirdClient.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 2. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBird.h"
#import "SendBirdChannel.h"
#import "SendBirdMessage.h"
#import "SendBirdSystemMessage.h"
#import "SendBirdFileLink.h"
#import "SendBirdWSClient.h"
#import "SendBirdAPIClient.h"
#import "SendBirdCommand.h"
#import "SendBirdBroadcastMessage.h"
#import "SendBirdMessagingChannel.h"
#import "SendBirdReadStatus.h"
#import "SendBirdTypeStatus.h"
#import "SendBirdError.h"
#import "SendBirdMember.h"
#import "SendBirdWSClient.h"
#import "SendBirdMention.h"
#import "SendBirdStructuredMessage.h"

//extern void (^onMessageReceived)(SendBirdMessage *message);
//extern void (^onSystemMessageReceived)(SendBirdSystemMessage *message);
//extern void (^onBroadcastMessageReceived)(SendBirdBroadcastMessage *message);
//extern void (^onFileReceived)(SendBirdFileLink *fileLink);
//extern void (^onMessagingStarted)(SendBirdMessagingChannel *channel);
//extern void (^onMessagingUpdated)(SendBirdMessagingChannel *channel);
//extern void (^onMessagingEnded)(SendBirdMessagingChannel *channel);
//extern void (^onReadReceived)(SendBirdReadStatus *status);
//extern void (^onTypeStartReceived)(SendBirdTypeStatus *status);
//extern void (^onTypeEndReceived)(SendBirdTypeStatus *status);

//enum SendBirdDataType;

@interface SendBirdClient : NSObject

- (id) initWithAppId:(NSString *)appId;
- (void) setEventHandlerConnectBlock:(void (^)(SendBirdChannel *channel))connect errorBlock:(void (^)(NSInteger code))error channelLeftBlock:(void (^)(SendBirdChannel *channel))channelLeft messageReceivedBlock:(void (^)(SendBirdMessage *message))messageReceived systemMessageReceivedBlock:(void (^)(SendBirdSystemMessage *message))systemMessageReceived broadcastMessageReceivedBlock:(void (^)(SendBirdBroadcastMessage *message))broadcastMessageReceived fileReceivedBlock:(void (^)(SendBirdFileLink *fileLink))fileReceived messagingStartedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingStarted messagingUpdatedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingUpdated messagingEndedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingEnded allMessagingEndedBlock:(void (^)())allMessagingEnded messagingHiddenBlock:(void (^)(SendBirdMessagingChannel *channel))messagingHidden allMessagingHiddenBlock:(void (^)())allMessagingHidden readReceivedBlock:(void (^)(SendBirdReadStatus *status))readReceived typeStartReceivedBlock:(void (^)(SendBirdTypeStatus *status))typeStartReceived typeEndReceivedBlock:(void (^)(SendBirdTypeStatus *status))typeEndReceived allDataReceivedBlock:(void (^)(NSUInteger sendBirdDataType, int count))allDataReceived messageDeliveryBlock:(void (^)(BOOL send, NSString *message, NSString *data, NSString *tempId))messageDelivery;

// TODO
//- (void) setEventHandlerConnectBlock:(void (^)(SendBirdChannel *channel))connect errorBlock:(void (^)(NSInteger code))error channelLeftBlock:(void (^)(SendBirdChannel *channel))channelLeft messageReceivedBlock:(void (^)(SendBirdMessage *message))messageReceived systemMessageReceivedBlock:(void (^)(SendBirdSystemMessage *message))systemMessageReceived broadcastMessageReceivedBlock:(void (^)(SendBirdBroadcastMessage *message))broadcastMessageReceived fileReceivedBlock:(void (^)(SendBirdFileLink *fileLink))fileReceived structuredMessageReceivedBlock:(void (^)(SendBirdStructuredMessage *message))structuredMessageReceived messagingStartedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingStarted messagingUpdatedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingUpdated messagingEndedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingEnded allMessagingEndedBlock:(void (^)())allMessagingEnded messagingHiddenBlock:(void (^)(SendBirdMessagingChannel *channel))messagingHidden allMessagingHiddenBlock:(void (^)())allMessagingHidden readReceivedBlock:(void (^)(SendBirdReadStatus *status))readReceived typeStartReceivedBlock:(void (^)(SendBirdTypeStatus *status))typeStartReceived typeEndReceivedBlock:(void (^)(SendBirdTypeStatus *status))typeEndReceived allDataReceivedBlock:(void (^)(NSUInteger sendBirdDataType, int count))allDataReceived messageDeliveryBlock:(void (^)(BOOL send, NSString *message, NSString *data, NSString *tempId))messageDelivery;

- (NSString *) getUserID;
- (NSString *) getUserName;
//- (void) setLastMessageLimit:(int)limit;
- (void) setLoginInfoWithUserId:(NSString *)userId andUserName:(NSString *)userName andUserImageUrl:(NSString *)imageUrl andAccessToken:(NSString *)accessToken andDeviceId:(NSString *)deviceId;
- (void) setChannelUrl:(NSString *)channelUrl;
- (NSString *) getChannelUrl;
- (SendBirdChannel *) getCurrentChannel;
- (void) connectWithMaxMessageTs:(long long)maxMessageTs;
- (void) cancelAll;
- (void) disconnect;
- (void) registerNotificationHandlerMessagingChannelUpdatedBlock:(void (^)(SendBirdMessagingChannel *channel))messagingChannelUpdated mentionUpdatedBlock:(void (^)(SendBirdMention *mention))mentionUpdated;
- (void) unregisterNotificationHandlerMessagingChannelUpdatedBlock;
- (void) cmdMessage:(NSString *)message withData:(NSString *)data andTempId:(NSString *)tempId mentionedUserIds:(NSArray *)mentionedUserIds;
- (void) markAsRead;
- (void) markAsReadForChannelUrl:(NSString *)channelUrl;
- (void) markAllAsRead;
- (void) getChannelListInPage:(int)page withQuery:(NSString *)query withLimit:(int)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
//- (void) getMessagingListWithResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) getMessagingListV2WithToken:(NSString *)token andPage:(int)page withLimit:(int)limit andShowEmpty:(BOOL)showEmpty resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messageListInChannelUrl:(NSString *)channelUrl withMessageTs:(long long)messageTs prevLimit:(int)prevLimit andNextLimit:(int)nextLimit include:(BOOL)include resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) leaveChannel:(NSString *)channelUrl;
- (void) getBlockedUserListResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) uploadFile:(NSData *)file type:(NSString *)type size:(unsigned long)size customField:(NSString *)customField uploadBlock:(void (^)(SendBirdFileInfo *fileInfo, NSError *error))onUpload;
- (void) cmdFile:(SendBirdFileInfo *)fileInfo;
//- (void) saveCursor;
//- (long long) loadCursorWithChannelUrl:(NSString *)channelUrl;
//- (void) setLastMessageMills:(long long)lastMessageMills;
//- (long long) getLastMessageMills;
- (void) messageReceived:(SendBirdMessage *)msg;
- (void) systemMessageReceived:(SendBirdSystemMessage *)msg;
- (void) broadcastMessageReceived:(SendBirdBroadcastMessage *)msg;
- (void) fileReceived:(SendBirdFileLink *)fileLink;
- (void) messagingStarted:(SendBirdMessagingChannel *)channel;
- (void) messagingEnded:(SendBirdMessagingChannel *)channel;
- (void) endAllMessaging;
- (void) typeStart:(SendBirdTypeStatus *)status;
- (void) typeEnd:(SendBirdTypeStatus *)status;
- (void) startMessagingWithGuestIds:(NSArray *)guestIds;
- (void) endMessagingWithChannelUrl:(NSString *)channelUrl;
- (void) hideMessagingWithChannelUrl:(NSString *)channelUrl;
- (void) hideAllMessaging;
- (void) cmdRead;
- (void) cmdTypeStart;
- (void) cmdTypeEnd;
//- (void) loadPrevMessagesWithLimit:(int)limit;
//- (void) loadPrevMessagesWithMinMessageId:(long long)minMessageId andLimit:(int)limit;
//- (void) loadNextMessagesWithLimit:(int)limit;
//- (void) loadNextMessagesWithMaxMessageId:(long long)maxMessageId andLimit:(int)limit;
//- (void) endCursorMode;
//- (BOOL) isCursorMode;
//- (void) startCursorModeWithCursor:(long long)cursor prevLimit:(int)prevLimit andNextLimit:(int)nextLimit;
//- (void) loadMessagesWithCursor:(long long)cursor prevLimit:(int)prevLimit andNextLimit:(int)nextLimit;
//- (void) loadMoreMessagesWithLimit:(int)limit;
- (void) getMemberListInChannel:(NSString *)channelUrl withPageNum:(int)page withQuery:(NSString *)query withLimit:(int)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) getMessagingUnreadCountResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) joinMessagingWithChannelUrl:(NSString *)channelUrl;
- (void) inviteMessagingWithChannelUrl:(NSString *)channelUrl andGuestIds:(NSArray *)guestIds;
//- (long long)getMaxMessageTs;
- (enum WSReadyState) connectState;
- (void) onlineMemberCount:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) userListWithToken:(NSString *)token page:(long)page withLimit:(long)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
@end
