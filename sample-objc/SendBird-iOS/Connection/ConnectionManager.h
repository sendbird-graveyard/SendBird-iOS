//
//  ConnectionManager.h
//  SendBird-iOS
//
//  Created by gyuyoung Hwang on 2018. 2. 7..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const _Nonnull ConnectionManagerErrorDomainConnection;
FOUNDATION_EXTERN NSString *const _Nonnull ConnectionManagerErrorDomainUser;

@class SBDUser;

@interface ConnectionManager : NSObject

+ (void)connectWithUserId:(nonnull NSString *)userId nickname:(nonnull NSString *)nickname completionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler;

@end
