//
//  SendBirdWSClient.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 3. 3. in San Francisco, CA.
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendBirdSRWebSocket.h"
#import "SendBirdCommand.h"
#import "SendBird.h"

enum WSReadyState {
    WS_CONNECTING   = 0,
    WS_OPEN         = 1,
    WS_CLOSING      = 2,
    WS_CLOSED       = 3,
};

@interface SendBirdWSClient : NSObject<SendBirdSRWebSocketDelegate>

- (id) initWithHost:(NSString *)host;
- (void) setEventHandlerOpenBlock:(void (^)())open messageBlock:(void (^)(NSString *data))message closeBlock:(void (^)())close errorBlock:(void (^)())error;
- (void) disconnect;
- (void) connect;
- (void) forceDisconnect;
- (BOOL) sendCommand:(SendBirdCommand *)command;
- (enum WSReadyState) connectState;

@end
