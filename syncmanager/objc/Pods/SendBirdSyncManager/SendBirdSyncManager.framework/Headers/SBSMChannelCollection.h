//
//  SBSMChannelCollection.h
//  SyncManager
//
//  Created by sendbird-young on 2018. 6. 20..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDBaseChannel+SyncManager.h"
#import "SBSMObject.h"
#import "SBSMCollection.h"
#import "SBSMConstants.h"
#import "SBSMChannelQuery.h"

@protocol SBSMChannelQuery;
@class SBSMChannelCollection;

@protocol SBSMChannelCollectionDelegate <NSObject>

- (void)collection:(nonnull SBSMChannelCollection *)collection didReceiveEvent:(SBSMChannelEventAction)action channels:(nonnull NSArray <SBDGroupChannel *> *)channels;

@end

@interface SBSMChannelCollection : NSObject <SBSMCollection>

@property (weak, atomic, nullable) id<SBSMChannelCollectionDelegate> delegate;
@property (strong, nonatomic, readonly, nonnull) id<SBSMChannelQuery> query;
@property (strong, nonatomic, readonly, nonnull) NSArray <SBDGroupChannel *> *channels;

/**
 *  DO NOT USE this initializer. Use `initWithQuery:` instead.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

+ (nullable instancetype)collectionWithQuery:(id<SBSMChannelQuery> _Nonnull)query;
- (nullable instancetype)initWithQuery:(id<SBSMChannelQuery> _Nonnull)query
NS_DESIGNATED_INITIALIZER;
- (void)remove;

- (void)fetchWithCompletionHandler:(nullable SBSMErrorHandler)completionHandler;

@end

