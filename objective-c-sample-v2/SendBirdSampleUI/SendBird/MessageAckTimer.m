//
//  MessageAckTimer.m
//  SendBird Sample UI
//
//  Created by Jed Gyeong on 6/19/18.
//  Copyright © 2018 SENDBIRD.COM. All rights reserved.
//

#import "MessageAckTimer.h"

@interface MessageAckTimer()

@property (strong) NSMutableDictionary<NSString *, NSTimer *> *ackTimer;
@property (atomic) NSTimeInterval timeout;

@end

@implementation MessageAckTimer

- (instancetype)initWithTimeout:(NSTimeInterval)timeout {
    self = [super init];
    
    if (self) {
        self.ackTimer = [[NSMutableDictionary alloc] init];
        self.timeout = timeout;
    }
    
    return self;
}

- (void)registerAckTimer:(NSString *)data {
    NSString *key = nil;
    if (data != nil) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(extractAckKeyFromData:)]) {
            key = [self.delegate extractAckKeyFromData:data];
        }
        else {
            key = data;
        }
        
        if (key != nil) {
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer * _Nonnull timer) {
                if (self.ackTimer[key] != nil) {
                    [self.ackTimer removeObjectForKey:key];
                }
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(messageDeliveryFailed:)]) {
                    [self.delegate messageDeliveryFailed:key];
                }
            }];
            self.ackTimer[key] = timer;
        }
    }
}

- (void)unregisterAckTimer:(NSString *)data {
    NSString *key = nil;
    if (data != nil) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(extractAckKeyFromData:)]) {
            key = [self.delegate extractAckKeyFromData:data];
        }
        else {
            key = data;
        }
        
        if (key != nil) {
            if (self.ackTimer[key] != nil) {
                [self.ackTimer[key] invalidate];
                [self.ackTimer removeObjectForKey:key];
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(messageDelivered:)]) {
                    [self.delegate messageDelivered:key];
                }
            }
        }
    }
}

@end
