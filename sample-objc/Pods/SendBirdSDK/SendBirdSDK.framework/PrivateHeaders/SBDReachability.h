//
//  SBDReachability.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 4/11/17.
//  Copyright © 2017 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    SBDNotReachable = 0,
    SBDReachableViaWiFi,
    SBDReachableViaWWAN
} SBDNetworkStatus;

extern NSString *kReachabilityChangedNotification;

@interface SBDReachability : NSObject

+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

- (BOOL)startNotifier;
- (void)stopNotifier;

- (SBDNetworkStatus)currentReachabilityStatus;

- (BOOL)connectionRequired;

@end
