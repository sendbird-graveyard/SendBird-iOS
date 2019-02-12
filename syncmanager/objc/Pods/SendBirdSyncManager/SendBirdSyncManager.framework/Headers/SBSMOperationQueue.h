//
//  SBSMOperationQueue.h
//  SyncManager
//
//  Created by sendbird-young on 2018. 8. 31..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSMOperation.h"

@interface SBSMOperationQueue : NSObject

+ (nullable instancetype)queue;
- (void)setMaxConcurrentOperationCount:(NSUInteger)count;
- (nonnull SBSMOperation *)enqueue:(nonnull void(^)(void))taskBlock synchronous:(BOOL)synchronous;
- (nonnull SBSMOperation *)enqueue:(nonnull void(^)(void))taskBlock;
- (void)resume;
- (void)pause;

@end
