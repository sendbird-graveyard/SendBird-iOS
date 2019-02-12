//
//  SBSMChannelQuery+Manager.h
//  SyncManager
//
//  Created by sendbird-young on 2018. 6. 21..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSMConstants.h"

@protocol SBSMChannelQuery <NSObject, NSCopying>

- (nonnull instancetype)copy;
- (nonnull NSPredicate *)predicate;
- (void)loadNextPageWithCompletionHandler:(nonnull SBSMChannelQueryCompletionHandler)completionHandler;
- (NSUInteger)limit;
- (BOOL)hasNext;

@end

