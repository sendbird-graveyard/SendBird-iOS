//
//  SBSMMessageCollection.h
//  SyncManager
//
//  Created by gyuyoung Hwang on 23/06/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSMCollection.h"
#import "SBSMConstants.h"

@class SBDBaseMessage, SBDGroupChannel;
@class SBSMMessageCollection, SBSMMessageFilter;

@protocol SBSMMessageCollectionDelegate <NSObject>

- (void)collection:(nonnull SBSMMessageCollection *)collection didReceiveEvent:(SBSMMessageEventAction)action messages:(nonnull NSArray <SBDBaseMessage *> *)messages;

@end

@interface SBSMMessageCollection : NSObject <SBSMCollection>

@property (weak, atomic, nullable) id<SBSMMessageCollectionDelegate> delegate;
@property (strong, nonatomic, readonly, nonnull) NSArray <SBDBaseMessage *> *messages;
@property (strong, nonatomic, readonly, nonnull) SBDGroupChannel *channel;
@property (atomic) NSUInteger limit;
@property (atomic) BOOL reverse;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
- (nullable instancetype)init NS_UNAVAILABLE;
#pragma clang diagnostic pop

#pragma mark - initializer
- (nonnull instancetype)initWithChannel:(nonnull SBDGroupChannel *)channel filter:(nullable SBSMMessageFilter *)filter viewpointTimestamp:(long long)viewpointTimestamp limit:(NSUInteger)limit reverse:(BOOL)reverse
NS_DESIGNATED_INITIALIZER;
+ (nonnull instancetype)collectionWithChannel:(nonnull SBDGroupChannel *)channel filter:(nullable SBSMMessageFilter *)filter viewpointTimestamp:(long long)viewpointTimestamp;
+ (void)createWithChannelUrl:(nonnull NSString *)channelUrl filter:(nullable SBSMMessageFilter *)filter viewpointTimestamp:(long long)viewpointTimestamp completionHandler:(nonnull SBSMMessageCollectionHandler)completionHandler;
- (void)resetViewpointTimestamp:(long long)viewpointTimestamp;
- (void)remove;

#pragma mark - load
- (void)fetchInDirection:(SBSMMessageDirection)direction completionHandler:(nullable SBSMErrorHandler)completionHandler;

#pragma mark - current user's message
- (void)appendMessage:(nonnull SBDBaseMessage *)message;
- (void)updateMessage:(nonnull SBDBaseMessage *)message;
- (void)deleteMessage:(nonnull SBDBaseMessage *)message;

@end
