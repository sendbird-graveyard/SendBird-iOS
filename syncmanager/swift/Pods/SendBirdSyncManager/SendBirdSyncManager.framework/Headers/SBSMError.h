//
//  SBSMError.h
//  SendBirdSyncManager
//
//  Created by sendbird-young on 26/01/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

#ifndef SBSMError_h
#define SBSMError_h

typedef NS_ENUM(NSUInteger, SBSMErrorCode) {
    SBSMErrorCodeDuplicatedFetch = 1000100,
    SBSMErrorCodeUserIdDoesNotExist = 1000110,
    
    SBSMErrorCodeFailedInitializationDatabase = 1000200,
    SBSMErrorCodeDatabaseIOError = 1000210,
    
    SBSMErrorCodeInvalidParameter = 1000300,
    SBSMErrorCodeNotEnoughParameter,
    SBSMErrorCodeInvalidTimeRange,
};

#endif /* SBSMError_h */
