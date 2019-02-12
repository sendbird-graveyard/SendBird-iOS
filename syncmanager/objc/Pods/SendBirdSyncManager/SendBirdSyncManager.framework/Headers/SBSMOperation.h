//
//  SBSMOperation.h
//  SyncManager
//
//  Created by sendbird-young on 2018. 8. 9..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBSMCommand;

@interface SBSMOperation : NSOperation

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

- (void)complete;

@end
