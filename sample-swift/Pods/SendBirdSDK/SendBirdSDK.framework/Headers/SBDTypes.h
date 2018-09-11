//
//  SBDTypes.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 6/24/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#ifndef SBDTypes_h
#define SBDTypes_h

#define CHANNEL_TYPE_OPEN @"open"
#define CHANNEL_TYPE_GROUP @"group"

#define SBD_PUSH_TEMPLATE_DEFAULT @"default"
#define SBD_PUSH_TEMPLATE_ALTERNATIVE @"alternative"

/**
 *  The order type for `SBDGroupChannelListQuery`.
 */
typedef NS_ENUM(NSInteger, SBDGroupChannelListOrder) {
    /**
     *  Chronological order for group channel.
     */
    SBDGroupChannelListOrderChronological           = 0,
    /**
     *  Lastest last message order for group channel.
     */
    SBDGroupChannelListOrderLatestLastMessage       = 1,
    /**
     *  Alphabetical name order for group channel.
     */
    SBDGroupChannelListOrderChannelNameAlphabetical = 2,
};

/**
 *  The order type for `SBDPublicGroupChannelListQuery`.
 */
typedef NS_ENUM(NSUInteger, SBDPublicGroupChannelListOrder) {
    /**
     *  Chronological order for public group channel.
     */
    SBDPublicGroupChannelListOrderChronological           = 0,
    /**
     *  Alphabetical name order for public group channel.
     */
    SBDPublicGroupChannelListOrderChannelNameAlphabetical = 2,
};

/**
 *  Error types.
 */
typedef NS_ENUM(NSInteger, SBDErrorCode) {
    // RESTful API Errors
    SBDErrorInvalidParameterValueString = 400100,
    SBDErrorInvalidParameterValueNumber = 400101,
    SBDErrorInvalidParameterValueList = 400102,
    SBDErrorInvalidParameterValueJson = 400103,
    SBDErrorInvalidParameterValueBoolean = 400104,
    SBDErrorInvalidParameterValueRequired = 400105,
    SBDErrorInvalidParameterValuePositive = 400106,
    SBDErrorInvalidParameterValueNegative = 400107,
    SBDErrorNonAuthorized = 400108,
    SBDErrorTokenExpired = 400109,
    SBDErrorInvalidChannelUrl = 400110,
    SBDErrorInvalidParameterValue = 400111,
    SBDErrorUnusableCharacterIncluded = 400151,
    SBDErrorNotFoundInDatabase = 400201,
    SBDErrorDuplicatedData = 400202,
    
    SBDErrorUserDeactivated = 400300,
    SBDErrorUserNotExist = 400301,
    SBDErrorAccessTokenNotValid = 400302,
    SBDErrorAuthUnknownError = 400303,
    SBDErrorAppIdNotValid = 400304,
    SBDErrorAuthUserIdTooLong = 400305,
    SBDErrorAuthPlanQuotaExceeded = 400306,
    
    SBDErrorInvalidApiToken = 400401,
    SBDErrorParameterMissing = 400402,
    SBDErrorInvalidJsonBody = 400403,
    
    SBDErrorInternalServerError = 500901,
    
    // SDK Internal Errors
    SBDErrorInvalidInitialization = 800100,
    SBDErrorConnectionRequired = 800101,
    SBDErrorInvalidParameter = 800110,
    SBDErrorNetworkError = 800120,
    SBDErrorNetworkRoutingError = 800121,
    SBDErrorMalformedData = 800130,
    SBDErrorMalformedErrorData = 800140,
    SBDErrorWrongChannelType = 800150,
    SBDErrorMarkAsReadRateLimitExceeded = 800160,
    SBDErrorQueryInProgress = 800170,
    SBDErrorAckTimeout = 800180,
    SBDErrorLoginTimeout = 800190,
    SBDErrorWebSocketConnectionClosed = 800200,
    SBDErrorWebSocketConnectionFailed = 800210,
    SBDErrorRequestFailed = 800220,
    SBDErrorFileUploadCancelFailed = 800230,
    SBDErrorFileUploadCancelled = 800240,
	SBDErrorFileUploadTimeout = 800250,
};

/**
 *  Connection state
 */
typedef NS_ENUM(NSUInteger, SBDWebSocketConnectionState) {
    /**
     *  Connecting
     */
    SBDWebSocketConnecting = 0,
    /**
     *  Open
     */
    SBDWebSocketOpen = 1,
    /**
     *  Closing
     */
    SBDWebSocketClosing = 2,
    /**
     *  Closed
     */
    SBDWebSocketClosed = 3,
};

/**
 *  User connection statuses for `SBDUser`.
 */
typedef NS_ENUM(NSUInteger, SBDUserConnectionStatus) {
    /**
     *  For unavailable user.
     */
    SBDUserConnectionStatusNonAvailable = 0,
    /**
     *  For on-line user.
     */
    SBDUserConnectionStatusOnline = 1,
    /**
     *  For off-line user.
     */
    SBDUserConnectionStatusOffline = 2,
};

/**
 *  Channel types.
 */
typedef NS_ENUM(NSUInteger, SBDChannelType) {
    /**
     *  Open channel.
     */
    SBDChannelTypeOpen = 0,
    /**
     *  Group channel.
     */
    SBDChannelTypeGroup = 1,
};

/**
 *  Push token registration statuses
 */
typedef NS_ENUM(NSUInteger, SBDPushTokenRegistrationStatus) {
    /**
     *  Registration succeeded.
     */
    SBDPushTokenRegistrationStatusSuccess = 0,
    /**
     *  Registration is pending.
     */
    SBDPushTokenRegistrationStatusPending = 1,
    /**
     *  Registartion is failed.
     */
    SBDPushTokenRegistrationStatusError = 2,
};

/**
 *  The query type for `SBDGroupChannelListQuery`.
 */
typedef NS_ENUM(NSInteger, SBDGroupChannelListQueryType) {
    SBDGroupChannelListQueryTypeAnd = 0,
    SBDGroupChannelListQueryTypeOr = 1,
};


/**
 Message type for filtering
 */
typedef NS_ENUM(NSInteger, SBDMessageTypeFilter) {
    /**
     * Filter of all messages.
     */
    SBDMessageTypeFilterAll = 0,
    /**
     *  Filter of user message.
     */
    SBDMessageTypeFilterUser = 1,
    /**
     *  Filter of file message.
     */
    SBDMessageTypeFilterFile = 2,
    /**
     *  Filter of admin message.
     */
    SBDMessageTypeFilterAdmin = 3,
};


/**
 Member state filter for group channel list query and group channel count
 */
typedef NS_ENUM(NSInteger, SBDMemberStateFilter) {
    /**
     * Filter of all member states.
     */
    SBDMemberStateFilterAll                 = 0,
    /**
     * Filter of joined state only.
     */
    SBDMemberStateFilterJoinedOnly          = 1,
    /**
     * Filter of invited state only. This contains SBDMemberStateFilterByFriend, SBDMemberStateFilterByNonFriend.
     */
    SBDMemberStateFilterInvitedOnly         = 2,
    /**
     * Filter of invited by friend state only.
     */
    SBDMemberStateFilterInvitedByFriend     = 3,
    /**
     * Filter of invited by non-friend state only.
     */
    SBDMemberStatefilterInvitedByNonFriend  = 4
};


/**
 Member state in group channel.
 */
typedef NS_ENUM(NSInteger, SBDMemberState) {
    /**
     * Filter of joined members in a group channel.
     */
    SBDMemberStateJoined = 0,
    /**
     * Filter of invited members in a group channel.
     */
    SBDMemberStateInvited = 1,
    /**
     * Filter of members neither joined or invited in a group channel.
     */
    SBDMemberStateNone = 2,
};

/**
 *  Channel filter for super mode in group channels.
 */
typedef NS_ENUM(NSUInteger, SBDGroupChannelSuperChannelFilter) {
    /**
     * Without filter
     */
    SBDGroupChannelSuperChannelFilterAll       = 0,
    /**
     * Filter super group channel.
     */
    SBDGroupChannelSuperChannelFilterSuper     = 1,
    /**
     * Filter non-super group channel.
     */
    SBDGroupChannelSuperChannelFilterNonSuper  = 2,
};

/**
 *  Filter public group channel or private one in group channels.
 */
typedef NS_ENUM(NSUInteger, SBDGroupChannelPublicChannelFilter) {
    /**
     * Without filter
     */
    SBDGroupChannelPublicChannelFilterAll       = 0,
    /**
     * Filter public group channel.
     */
    SBDGroupChannelPublicChannelFilterPublic    = 1,
    /**
     * Filter private group channel.
     */
    SBDGroupChannelPublicChannelFilterPrivate   = 2,
};

/**
 *  Filter my channels or all ones in public group channels.
 */
typedef NS_ENUM(NSUInteger, SBDPublicGroupChannelMembershipFilter) {
    /**
     * Without filter.
     */
    SBDPublicGroupChannelMembershipFilterAll      = 0,
    /**
     * Filter public group channel the current user joined in.
     */
    SBDPublicGroupChannelMembershipFilterJoined   = 1,
};

/**
 *  Filter operators in group channels.
 */
typedef NS_ENUM(NSUInteger, SBDGroupChannelOperatorFilter) {
    /**
     * Without filter.
     */
    SBDGroupChannelOperatorFilterAll            = 0,
    /**
     * Filter operators.
     */
    SBDGroupChannelOperatorFilterOperator      = 1,
    /**
     * Filter members except operators.
     */
    SBDGroupChannelOperatorFilterNonOperator   = 2,
};

/**
 *  Filter operators in group channels.
 */
typedef NS_ENUM(NSUInteger, SBDGroupChannelMutedMemberFilter) {
    /**
     * Without filter.
     */
    SBDGroupChannelMutedMemberFilterAll     = 0,
    /**
     * Filter muted members.
     */
    SBDGroupChannelMutedMemberFilterMuted   = 1,
    /**
     * Filter members not muted.
     */
    SBDGroupChannelMutedMemberFilterUnmuted = 2,
};


/**
 *  The push option that determines how to deliver the push notification when sending a user or a file message.
 */
typedef NS_ENUM(NSUInteger, SBDPushNotificationDeliveryOption) {
    /**
     *  The push notification will be delivered by the opposite user's setting.
     */
    SBDPushNotificationDeliveryOptionDefault = 0,
    /**
     *  The push notification will never be delivered.
     */
    SBDPushNotificationDeliveryOptionSuppress = 1,
};

/**
 *  The users's role which gives different behaviors, permisions to user.
 */
typedef NS_ENUM(NSUInteger, SBDRole) {
    /**
     *  The default role that means nothing.
     */
    SBDRoleNone = 0,
    /**
     *  The role of operator.
     */
    SBDRoleOperator = 1,
};

/**
 The current user's muted state type.

 - SBDMutedStateUnmuted: The current user is unmuted in the group channel.
 - SBDMutedStateMuted: The current user is muted in the group channel.
 */
typedef NS_ENUM(NSInteger, SBDMutedState) {
    
    SBDMutedStateUnmuted = 0,
    SBDMutedStateMuted = 1,
};

/**
 *  The bitmask keys of count about unread messages or invitation.
 */
typedef NS_OPTIONS(NSUInteger, SBDUnreadItemKey) {
    /**
     *  The bitmask key for unread message count of non super channel.
     */
    SBDUnreadItemKeyNonSuperUnreadMessageCount      = (1 << 0),
    /**
     *  The bitmask key for unread message count of super channel.
     */
    SBDUnreadItemKeySuperUnreadMessageCount         = (1 << 1),
    /**
     *  The bitmask key for invitation count of non super channel.
     */
    SBDUnreadItemKeyNonSuperInvitationCount         = (1 << 2),
    /**
     *  The bitmask key for invitation count of super channel.
     */
    SBDUnreadItemKeySuperInvitationCount            = (1 << 3),
    /**
     *  The bitmask key for unread mention count of non super channel.
     */
    SBDUnreadItemKeyNonSuperUnreadMentionCount      = (1 << 4),
    /**
     *  The bitmask key for unread mention count of non super channel.
     */
    SBDUnreadItemKeySuperUnreadMentionCount         = (1 << 5),
    
    
    /**
     *  The bitmask key for unread message count of group channel(super and non-super).
     */
    SBDUnreadItemKeyGroupChannelUnreadMessageCount  = (1 << 10),
    /**
     *  The bitmask key for unread mention count of group channel(super and non-super).
     */
    SBDUnreadItemKeyGroupChannelUnreadMentionCount  = (1 << 11),
    /**
     *  The bitmask key for invitation count of group channel(super and non-super).
     */
    SBDUnreadItemKeyGroupChannelInvitationCount     = (1 << 12),
};

/**
 *  The enum type to represent various kinds of counts.
 */
typedef NS_ENUM(NSUInteger, SBDCountPreference) {
    /**
     *  The channel of this preference has all of count.
     */
    SBDCountPreferenceAll = 0,
    /**
     *  The channel of this preference has only unread message count.
     */
    SBDCountPreferenceUnreadMessageCountOnly = 1,
    /**
     *  The channel of this preference has only unread mention count.
     */
    SBDCountPreferenceUnreadMentionCountOnly = 2,
    /**
     *  The channel of this preference does not get any count.
     */
    SBDCountPreferenceOff = 3,
};

/**
 *  The enum type to represent target type of mention.
 */
typedef NS_ENUM(NSUInteger, SBDMentionType) {
    SBDMentionTypeUsers = 0,
    SBDMentionTypeChannel = 1,
};

#endif /* SBDTypes_h */
