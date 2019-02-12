//
//  SBSMSyncManager.h
//  SendBirdSyncManager
//
//  Created by sendbird-young on 25/01/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBSMSyncManager : NSObject

+ (nonnull instancetype)setupWithUserId:(nonnull NSString *)userId;
+ (nonnull instancetype)manager;

- (void)resumeSynchronize;
- (void)pauseSynchronize;

- (void)clearCache;
+ (void)clearCache;

@end

NS_ASSUME_NONNULL_END
