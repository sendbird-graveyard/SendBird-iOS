//
//  ConnectionManager.m
//  SendBird-iOS
//
//  Created by gyuyoung Hwang on 2018. 2. 7..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import "ConnectionManager.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "NSBundle+SendBird.h"

NSString *const ConnectionManagerErrorDomainConnection = @"com.sendbird.sample.connection";
NSString *const ConnectionManagerErrorDomainUser = @"com.sendbird.sample.user";

@implementation ConnectionManager

+ (void)connectWithUserId:(nonnull NSString *)userId nickname:(nonnull NSString *)nickname completionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler {
    [SBDMain connectWithUserId:userId completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
        if (error != nil) {
            if (completionHandler != nil) {
                NSError *theError = [NSError errorWithDomain:ConnectionManagerErrorDomainConnection code:error.code userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription,
                                                                                                                          NSLocalizedFailureReasonErrorKey:error.localizedFailureReason,
                                                                                                                          NSUnderlyingErrorKey:error}];
                completionHandler(nil, theError);
            }
            return;
        }
        
        [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"APNS registration failed.");
                return;
            }
            if (status == SBDPushTokenRegistrationStatusPending) {
                NSLog(@"Push registration is pending.");
            }
            else {
                NSLog(@"APNS Token is registered.");
            }
        }];
        
        [SBDMain updateCurrentUserInfoWithNickname:nickname profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                if (completionHandler != nil) {
                    NSError *theError = [NSError errorWithDomain:ConnectionManagerErrorDomainUser code:error.code userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription,
                                                                                                                                   NSLocalizedFailureReasonErrorKey:error.localizedFailureReason,
                                                                                                                                   NSUnderlyingErrorKey:error}];
                    completionHandler(nil, theError);
                }
                return;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].userId forKey:@"sendbird_user_id"];
            [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].nickname forKey:@"sendbird_user_nickname"];
            
            if (completionHandler != nil) {
                completionHandler(user, nil);
            }
        }];
    }];
}

@end
