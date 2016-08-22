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

typedef NS_ENUM(NSInteger, SBDGroupChannelListOrder) {
    SBDGroupChannelListOrderChronological = 0,
    SBDGroupChannelListOrderLatestLastMessage = 1,
};

typedef NS_ENUM(NSInteger, SBDOpenChannelMetaCountersUpdateMode) {
    SBDOpenChannelUpdateModeSet = 0,
    SBDOpenChannelUpdateModeIncrease = 1,
    SBDOpenChannelUpdateModeDecrease = 2,
};

typedef NS_ENUM(NSInteger, SBDChannelEventCategory) {
    SBDChannelEventCategoryNone = 0,
    
    SBDChannelEventCategoryChannelEnter = 10102,
    SBDChannelEventCategoryChannelExit = 10103,
    
    SBDChannelEventCategoryChannelMute = 10201,
    SBDChannelEventCategoryChannelUnmute = 10200,
    
    SBDChannelEventCategoryChannelBan = 10601,
    SBDChannelEventCategoryChannelUnban = 10600,
    
    SBDChannelEventCategoryChannelFrozen = 10701,
    SBDChannelEventCategoryChannelUnfrozen = 10700,
    
    SBDChannelEventCategoryTypingStart = 10900,
    SBDChannelEventCategoryTypingEnd = 10901,
    
    SBDChannelEventCategoryChannelJoin = 10000,
    SBDChannelEventCategoryChannelLeave = 10001,
    
    SBDChannelEventCategoryChannelPropChanged = 11000,
    SBDChannelEventCategoryChannelDeleted = 12000,
};

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
    SBDErrorInvalidApiToken = 400401,
    SBDErrorParameterMissing = 400402,
    SBDErrorInvalidJsonBody = 400403,
    
    // RESTful API Errors for SDK
    SBDErrorAppIdNotValid = 400404,
    SBDErrorAccessTokenEmpty = 400500,
    SBDErrorAccessTokenNotValid = 400501,
    SBDErrorUserNotExist = 400502,
    SBDErrorUserDeactivated = 400503,
    SBDErrorUserCreationFailed = 400504,
    
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
};

/**
 *  Log level
 */
typedef NS_ENUM(NSInteger, SBDLogLevel) {
    /**
     *  None
     */
    SBDLogLevelNone = 0,
    /**
     *  Error
     */
    SBDLogLevelError = 1,
    /**
     *  Warning
     */
    SBDLogLevelWarning = 2,
    /**
     *  Information
     */
    SBDLogLevelInfo = 3,
    /**
     *  Debug
     */
    SBDLogLevelDebug = 4
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
    SBSWebSocketClosed = 3,
};

typedef NS_ENUM(NSUInteger, SBDUserConnectionStatus) {
    SBDUserConnectionStatusNonAvailable = 0,
    SBDUserConnectionStatusOnline = 1,
    SBDUserConnectionStatusOffline = 2,
};

typedef NS_ENUM(NSUInteger, SBDUserListQueryType) {
    SBDUserListQueryTypeAllUser = 1,
    SBDUserListQueryTypeBlockedUsers = 2,
    SBDUserListQueryTypeOpenChannelParticipants = 3,
    SBDUserListQueryTypeOpenChannelMutedUsers = 4,
    SBDUserListQueryTypeOpenChannelBannedUsers = 5,
};

typedef NS_ENUM(NSUInteger, SBDChannelType) {
    SBDChannelTypeOpen = 0,
    SBDChannelTypeGroup = 1,
};

#endif /* SBDTypes_h */
