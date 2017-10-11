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
    SBDGroupChannelListOrderChronological = 0,
    SBDGroupChannelListOrderLatestLastMessage = 1,
};

/**
 *  Error types.
 */
typedef NS_ENUM(NSInteger, SDBErrorCode) {
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
    SBDUserConnectionStatusNonAvailable = 0,
    SBDUserConnectionStatusOnline = 1,
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

 - SBDMessageTypeFilterAll: All.
 - SBDMessageTypeFilterUser: User message.
 - SBDMessageTypeFilterFile: File message.
 - SBDMessageTypeFilterAdmin: Admin message.
 */
typedef NS_ENUM(NSInteger, SBDMessageTypeFilter) {
    SBDMessageTypeFilterAll = 0,
    SBDMessageTypeFilterUser = 1,
    SBDMessageTypeFilterFile = 2,
    SBDMessageTypeFilterAdmin = 3,
};


/**
 Member state filter for group channel list query and group channel count

 - SBDMemberStateFilterAll: All.
 - SBDMemberStateFilterJoinedOnly: Joined state only.
 - SBDMemberStateFilterInvitedOnly: Invited state only.
 */
typedef NS_ENUM(NSInteger, SBDMemberStateFilter) {
    SBDMemberStateFilterAll = 0,
    SBDMemberStateFilterJoinedOnly = 1,
    SBDMemberStateFilterInvitedOnly = 2,
};


/**
 Member state in group channel.

 - SBDMemberStateJoined: Joined member in a group channel.
 - SBDMemberStateInvited: Invited member in a group channel.
 */
typedef NS_ENUM(NSInteger, SBDMemberState) {
    SBDMemberStateJoined = 0,
    SBDMemberStateInvited = 1,
};

#endif /* SBDTypes_h */
