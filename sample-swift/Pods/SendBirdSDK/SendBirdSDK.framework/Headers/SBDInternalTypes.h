//
//  SBDInternalTypes.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 8/18/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#ifndef SBDInternalTypes_h
#define SBDInternalTypes_h

typedef NS_ENUM(NSInteger, SBDChannelMetaCountersUpdateMode) {
    SBDChannelUpdateModeSet = 0,
    SBDChannelUpdateModeIncrease = 1,
    SBDChannelUpdateModeDecrease = 2,
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
    
    SBDChannelEventCategoryChannelInvite = 10020,
//    SBDChannelEventCategoryChannelAcceptInvite = 10021,
    SBDChannelEventCategoryChannelDeclineInvite = 10022,
    
    SBDChannelEventCategoryChannelPropChanged = 11000,
    SBDChannelEventCategoryChannelDeleted = 12000,
    
    SBDChannelEventCategoryMetaDataChanged = 11100,
    SBDChannelEventCategoryMetaCounterChanged = 11200,
    
    SBDChannelEventCategoryChannelHidden = 13000,
};

typedef NS_ENUM(NSInteger, SBDUserEventCategory) {
    SBDUserEventCategoryUserUnblock = 20000,
    SBDUserEventCategoryUserBlock = 20001,
    SBDUserEventCategoryUserFriendDiscoveryReady = 20900,
};

typedef NS_ENUM(NSUInteger, SBDUserListQueryType) {
    SBDUserListQueryTypeAllUser = 1,
    SBDUserListQueryTypeBlockedUsers = 2,
    SBDUserListQueryTypeOpenChannelParticipants = 3,
    SBDUserListQueryTypeOpenChannelMutedUsers = 4,
    SBDUserListQueryTypeOpenChannelBannedUsers = 5,
    SBDUserListQueryTypeFilteredUsers = 6,
};

typedef NS_ENUM(NSInteger, SBDLogLevel) {
    SBDLogLevelNone = 0,
    SBDLogLevelError = 1,
    SBDLogLevelWarning = 2,
    SBDLogLevelInfo = 3,
};

#endif /* SBDInternalTypes_h */
