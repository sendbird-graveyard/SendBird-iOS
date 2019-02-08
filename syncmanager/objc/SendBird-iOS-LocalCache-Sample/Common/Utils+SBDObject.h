//
//  Utils+SBDObject.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by sendbird-young on 03/02/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

#import "Utils.h"
#import <SendBirdSyncManager/SendBirdSyncManager.h>

NS_ASSUME_NONNULL_BEGIN

@class SBDBaseMessage, SBDBaseChannel;
@protocol SBSMObject;

#pragma mark - Index Object
@interface SBSMIndex : NSObject

@property (atomic, readonly) NSUInteger indexOfObject;
@property (atomic, readonly) NSUInteger indexOfPreviousObject;

+ (nullable instancetype)indexOfObject:(NSUInteger)indexOfObject indexOfPreviousObject:(NSUInteger)indexOfPreviousObject;
- (BOOL)containsObject;

@end

#pragma mark - Utils for SBDObject
@interface Utils (SBDObject)

//+ (nonnull SBSMIndex *)indexOfSendBirdObject:(id<SBSMObject> _Nonnull)object inSendBirdObjects:(NSArray<id<SBSMObject>> * _Nonnull)inObjects;
+ (nonnull SBSMIndex *)indexOfMessage:(nonnull SBDBaseMessage *)message inMessages:(nonnull NSArray<SBDBaseMessage *> *)inMessages;
+ (nonnull NSArray<SBSMIndex *> *)indexesOfMessages:(nonnull NSArray<SBDBaseMessage *> *)messages inMessages:(nonnull NSArray<SBDBaseMessage *> *)inMessages;
+ (nonnull SBSMIndex *)indexOfChannel:(nonnull SBDGroupChannel *)channel inChannels:(nonnull NSArray<SBDGroupChannel *> *)inChannels sortDescription:(nonnull SBSMChannelComparison)sortDescription;
+ (nonnull NSArray<SBSMIndex *> *)indexesOfChannels:(nonnull NSArray<SBDGroupChannel *> *)channels inChannels:(nonnull NSArray<SBDGroupChannel *> *)inChannels sortDescription:(nonnull SBSMChannelComparison)sortDescription;
+ (nonnull SBSMIndex *)indexOfMessageId:(long long)messageId ofMessages:(nonnull NSArray<SBDBaseMessage *> *)messages;
+ (nonnull SBSMIndex *)indexOfChannelUrl:(nonnull NSString *)channelUrl ofChannels:(nonnull NSArray<SBDBaseChannel *> *)channels;
//+ (nonnull NSArray<SBSMIndex *> *)indexesOfSendBirdObjects:(nonnull NSArray<id<SBSMObject>> *)objects inObjects:(nonnull NSArray<id<SBSMObject>> *)inObjects;

@end

NS_ASSUME_NONNULL_END
