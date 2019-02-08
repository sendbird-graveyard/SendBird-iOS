//
//  ConnectionManager.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by gyuyoung Hwang on 2018. 2. 7..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import "ConnectionManager.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import <SendBirdSyncManager/SendBirdSyncManager.h>

NSString *const ConnectionManagerErrorDomainConnection = @"com.sendbird.sample.connection";
NSString *const ConnectionManagerErrorDomainUser = @"com.sendbird.sample.user";

@interface ConnectionManager () <SBDConnectionDelegate>

@property (atomic, strong, nullable) NSMapTable<NSString *, id<ConnectionManagerDelegate>> *observers;

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
        _observers = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableWeakMemory];
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
    [SBSMSyncManager setupWithUserId:userId];
    
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
        
        SBSMSyncManager *manager = [SBSMSyncManager manager];
        [manager resumeSynchronize];
        
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
        
        [[SBSMSyncManager manager] clearCache];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"sendbird_user_id"];
        [userDefault removeObjectForKey:@"sendbird_user_nickname"];
        [userDefault synchronize];
        
        if (completionHandler != nil) {
            completionHandler();
        }
    }];
}

+ (void)addConnectionObserver:(id<ConnectionManagerDelegate>)observer {
    NSMapTable<NSString *, id<ConnectionManagerDelegate>> *observers = [[self sharedInstance] observers];
    if (observer != nil) {
        [observers setObject:observer forKey:[self instanceIdentifier:observer]];
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
    NSMapTable<NSString *, id<ConnectionManagerDelegate>> *observers = [[self sharedInstance] observers];
    if (observer != nil) {
        [observers removeObjectForKey:[self instanceIdentifier:observer]];
    }
}

- (void)broadcastConnection:(BOOL)isReconnection {
    NSEnumerator <id<ConnectionManagerDelegate>> *enumerator = [self.observers objectEnumerator];
    __weak id<ConnectionManagerDelegate> observer;
    while (observer = [enumerator nextObject]) {
        if ([observer respondsToSelector:@selector(didConnect:)]) {
            [observer didConnect:isReconnection];
        }
    }
}

- (void)broadcastDisconnection {
    NSEnumerator <id<ConnectionManagerDelegate>> *enumerator = [self.observers objectEnumerator];
    __weak id<ConnectionManagerDelegate> observer;
    while (observer = [enumerator nextObject]) {
        if ([observer respondsToSelector:@selector(didDisconnect)]) {
            [observer didDisconnect];
        }
    }
}

+ (nullable NSString *)instanceIdentifier:(nullable id)instance {
    if (instance == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%p_%@", instance, instance];
}

#pragma mark - SBD Connection Delegate
- (void)didStartReconnection {
    [self broadcastDisconnection];
}

- (void)didSucceedReconnection {
    SBSMSyncManager *manager = [SBSMSyncManager manager];
    [manager resumeSynchronize];
    
    [self broadcastConnection:YES];
}

- (void)didFailReconnection {
    
}

- (void)didCancelReconnection {
    
}

@end
