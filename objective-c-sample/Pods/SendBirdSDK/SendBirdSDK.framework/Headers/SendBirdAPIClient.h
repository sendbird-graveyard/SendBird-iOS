//
//  SendBirdAPIClient.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 1. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBird.h"

#define kApiGuestLogin @"/v1/guest_login"
#define kApiChannelList @"/v1/channel_list"
#define kApiChannelJoin @"/v1/channel_join"
#define kApiUploadFile @"/v1/upload_file"
#define kApiMessagingStart @"/v1/messaging_start"
#define kApiMessagingEnd @"/v1/messaging_end"
//#define kApiMessagingList @"/v1/messaging_list"
#define kApiMessagingListV2 @"/v2/messaging_list"
#define kApiLoadMoreMessages @"/v1/load_more_messages"
#define kApiMemberList @"/v1/member_list"
#define kApiMessagingJoin @"/v1/messaging_join"
#define kApiChannelLeave @"/v1/channel_leave"
#define kApiMessagingInvite @"/v1/messaging_invite"
#define kApiMessagingInfo @"/v1/messaging_info"
#define kApiMessageList @"/v1/message_list"
#define kApiMessagingHide @"/v1/messaging_hide"
#define kApiMarkAsRead @"/v1/mark_as_read"
#define kApiMessagingUnreadCount @"/v1/messaging_unread_count"
#define kApiUserBlockList @"/v1/user_block_list"
#define kApiUserList @"/v1/user_list"
#define kApiOnlineMemberCount @"/v1/online_member_count"

@interface SendBirdAPIClient : NSObject

@property (retain) NSString *appId;
@property (retain) NSString *sessionKey;

- (id) initWithAppId:(NSString *)appId;
- (void) channelListInPage:(int)page withQuery:(NSString *)query withLimit:(int)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) guestLoginWithGuestId:(NSString *)guestId andNickname:(NSString *)nickname andUserImageUrl:(NSString *)imageUrl andAccessToken:(NSString *)accessToken andDeviceId:(NSString *)deviceId resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) post:(NSString *)uri form:(NSMutableDictionary *)form resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) joinChannel:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) leaveChannel:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) uploadFile:(NSData *)file resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingStartWithGuestIds:(NSArray *)guestIds resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) markAsReadForChannelUrl:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) markAllAsReadWithResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingJoinWithChannelUrl:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingInviteWithChannelUrl:(NSString *)channelUrl andGuestIds:(NSArray *)guestIds resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingEndWithChannelUrl:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingEndAllWithResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingHideWithChannelUrl:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingHideAllWithResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingInfoOfChannelId:(long long)channelId resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingInfoMessageOnlyOfChannelId:(long long)channelId resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
//- (void) messagingListResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingListV2WithToken:(NSString *)token andPage:(int)page withLimit:(int)limit andShowEmpty:(BOOL)showEmpty resultBlock:(void (^)(NSDictionary *, NSError *))onResult;
- (void) loadMoreMessagesInChannel:(long long)channelId andMinMessageTs:(long long)minMessageTs withLimit:(int)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) memberListInChannel:(NSString *)channelUrl withPageNum:(int)page withQuery:(NSString *)query withLimit:(int)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messageListWithChannelUrl:(NSString *)channelUrl messageTs:(long long)messageTs prevLimit:(int)prevLimit andNextLimit:(int)nextLimit include:(BOOL)include resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) messagingUnreadCountResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) onlineMemberCount:(NSString *)channelUrl resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) userListWithToken:(NSString *)token page:(long)page withLimit:(long)limit resultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;
- (void) cancelAll;
- (void) getBlockedUserListResultBlock:(void (^)(NSDictionary *response, NSError *error))onResult;

@end
