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

@interface ConnectionManager () <SBDConnectionDelegate>

@property (atomic, strong) NSMutableArray<id<ConnectionManagerDelegate>> *observers;

@end

@implementation ConnectionManager

+ (nullable instancetype)sharedInstance {
    static ConnectionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConnectionManager alloc] init];
    });
    return instance;
}

- (nullable instancetype)init {
    self = [super init];
    if (self) {
        _observers = [NSMutableArray array];
        [SBDMain addConnectionDelegate:self identifier:self.description];
    }
    return self;
}

- (void)dealloc {
    [SBDMain removeConnectionDelegateForIdentifier:self.description];
}

+ (void)loginWithCompletionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    NSString *userNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_nickname"];
    
    if (userId == nil || userId.length == 0 || userNickname == nil || userNickname.length == 0) {
        if (completionHandler != nil) {
            NSError *error = [NSError errorWithDomain:ConnectionManagerErrorDomainConnection code:-1 userInfo:@{NSLocalizedDescriptionKey:@"user id or user nickname is nil.",
                                                                                                                NSLocalizedFailureReasonErrorKey:@"Saved user data does not exist."}];
            completionHandler(nil, error);
        }
        return;
    }
    
    [self loginWithUserId:userId nickname:userNickname completionHandler:completionHandler];
}

+ (void)loginWithUserId:(nonnull NSString *)userId nickname:(nonnull NSString *)nickname completionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler {
    [[self sharedInstance] loginWithUserId:userId nickname:nickname completionHandler:completionHandler];
}

- (void)loginWithUserId:(nonnull NSString *)userId nickname:(nonnull NSString *)nickname completionHandler:(nullable void(^)(SBDUser * _Nullable user, NSError * _Nullable error))completionHandler {
    [SBDMain connectWithUserId:userId completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
        if (error != nil) {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault removeObjectForKey:@"sendbird_user_id"];
            [userDefault removeObjectForKey:@"sendbird_user_nickname"];
            [userDefault synchronize];
            
            if (completionHandler != nil) {
                NSError *theError = [NSError errorWithDomain:ConnectionManagerErrorDomainConnection code:error.code userInfo:@{NSLocalizedDescriptionKey:(error.localizedDescription ? : @""),
                                                                                                                               NSLocalizedFailureReasonErrorKey:(error.localizedFailureReason ? : @""),
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
        
        [self broadcastConnection:NO];
        
        [SBDMain updateCurrentUserInfoWithNickname:nickname profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                [self logoutWithCompletionHandler:^{
                    if (completionHandler != nil) {
                        NSError *theError = [NSError errorWithDomain:ConnectionManagerErrorDomainUser code:error.code userInfo:@{NSLocalizedDescriptionKey:(error.localizedDescription ? : @""),
                                                                                                                                 NSLocalizedFailureReasonErrorKey:(error.localizedFailureReason ? : @""),
                                                                                                                                 NSUnderlyingErrorKey:error}];
                        completionHandler(nil, theError);
                    }
                }];
                return;
            }
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[SBDMain getCurrentUser].userId forKey:@"sendbird_user_id"];
            [userDefault setObject:[SBDMain getCurrentUser].nickname forKey:@"sendbird_user_nickname"];
            [userDefault synchronize];
            
            if (completionHandler != nil) {
                completionHandler(user, nil);
            }
        }];
    }];
}

+ (void)logoutWithCompletionHandler:(nullable void(^)(void))completionHandler {
    [[self sharedInstance] logoutWithCompletionHandler:completionHandler];
}

- (void)logoutWithCompletionHandler:(nullable void(^)(void))completionHandler {
    [SBDMain disconnectWithCompletionHandler:^{
        [self broadcastDisconnection];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"sendbird_user_id"];
        [userDefault removeObjectForKey:@"sendbird_user_nickname"];
        [userDefault synchronize];
    }];
}

+ (void)addConnectionObserver:(id<ConnectionManagerDelegate>)observer {
    NSMutableArray<id<ConnectionManagerDelegate>> *observers = [[self sharedInstance] observers];
    if (![observers containsObject:observer]) {
        [observers addObject:observer];
    }
    
    if ([SBDMain getConnectState] == SBDWebSocketOpen) {
        if ([observer respondsToSelector:@selector(didConnect:)]) {
            [observer didConnect:NO];
        }
    }
    else if ([SBDMain getConnectState] == SBDWebSocketClosed) {
        [self loginWithCompletionHandler:nil];
    }
}

+ (void)removeConnectionObserver:(id<ConnectionManagerDelegate>)observer {
    NSMutableArray<id<ConnectionManagerDelegate>> *observers = [[self sharedInstance] observers];
    if ([observers containsObject:observer]) {
        [observers removeObject:observer];
    }
}

- (void)broadcastConnection:(BOOL)isReconnection {
    NSArray<id<ConnectionManagerDelegate>> *observers = [self.observers copy];
    for (id<ConnectionManagerDelegate> observer in observers) {
        if ([observer respondsToSelector:@selector(didConnect:)]) {
            [observer didConnect:isReconnection];
        }
    }
}

- (void)broadcastDisconnection {
    NSArray<id<ConnectionManagerDelegate>> *observers = [self.observers copy];
    for (id<ConnectionManagerDelegate> observer in observers) {
        if ([observer respondsToSelector:@selector(didDisconnect)]) {
            [observer didDisconnect];
        }
    }
}

#pragma mark - SBD Connection Delegate
- (void)didStartReconnection {
    [self broadcastDisconnection];
}

- (void)didSucceedReconnection {
    [self broadcastConnection:YES];
}

- (void)didFailReconnection {
    
}

- (void)didCancelReconnection {
    
}

@end
