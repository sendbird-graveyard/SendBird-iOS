//
//  Utils+SBDObject.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by sendbird-young on 03/02/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

#import "Utils+SBDObject.h"

@implementation SBSMIndex

- (instancetype)init {
    self = [super init];
    if (self) {
        _indexOfObject = NSNotFound;
        _indexOfPreviousObject = NSNotFound;
    }
    return self;
}

+ (instancetype)indexOfObject:(NSUInteger)indexOfObject indexOfPreviousObject:(NSUInteger)indexOfPreviousObject {
    SBSMIndex *index = [[SBSMIndex alloc] init];
    [index setIndexOfObject:indexOfObject];
    [index setIndexOfPreviousObject:indexOfPreviousObject];
    return index;
}

- (void)setIndexOfObject:(NSUInteger)indexOfObject {
    _indexOfObject = indexOfObject;
}

- (void)setIndexOfPreviousObject:(NSUInteger)indexOfPreviousObject {
    _indexOfPreviousObject = indexOfPreviousObject;
}

- (BOOL)containsObject {
    return (self.indexOfObject != NSNotFound);
}


@end

@implementation Utils (SBDObject)

//+ (SBSMIndex *)indexOfSendBirdObject:(id<SBSMObject>)object inSendBirdObjects:(NSArray<id<SBSMObject>> *)inObjects {
//    NSObject *sbObject = (NSObject *)object;
//    if ([sbObject isKindOfClass:[SBDBaseMessage class]]) {
//        SBDBaseMessage *message = (SBDBaseMessage *)object;
//        NSArray<SBDBaseMessage *> *inMessages = (NSArray<SBDBaseMessage *> *)inObjects;
//        return [self indexOfMessage:message inMessages:inMessages];
//    }
//    else if ([sbObject isKindOfClass:[SBDGroupChannel class]]) {
//        SBDGroupChannel *channel = (SBDGroupChannel *)object;
//        NSArray<SBDGroupChannel *> *inChannels = (NSArray<SBDGroupChannel *> *)inObjects;
//        return [self indexOfChannel:channel inChannels:channel sortDescription:<#^NSComparisonResult(SBDGroupChannel *, SBDGroupChannel *)sortDescription#>
//    }
//    else {
//        return [[SBSMIndex alloc] init];
//    }
//}

+ (SBSMIndex *)indexOfMessage:(SBDBaseMessage *)message inMessages:(NSArray<SBDBaseMessage *> *)inMessages {
    if (message == nil || inMessages.count == 0) {
        return [[SBSMIndex alloc] init];
    }
    
    BOOL reverse = NO;
    if (inMessages.firstObject.createdAt > inMessages.lastObject.createdAt) {
        reverse = YES;
    }
    
    long long earliestCreatedAt = MIN(inMessages.firstObject.createdAt, inMessages.lastObject.createdAt);
    long long latestCreatedAt = MAX(inMessages.firstObject.createdAt, inMessages.lastObject.createdAt);
    
    if (message.createdAt < earliestCreatedAt) {
        NSUInteger indexOfPreviousMessage = reverse ? (inMessages.count - 1) : NSNotFound;
        return [SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:indexOfPreviousMessage];
    }
    else if (latestCreatedAt < message.createdAt) {
        NSUInteger indexOfPreviousMessage = reverse ? NSNotFound : (inMessages.count - 1);
        return [SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:indexOfPreviousMessage];
    }
    
    NSUInteger index = reverse ? (inMessages.count - 1) : 0;
    while (index >= 0 && index < inMessages.count) {
        SBDBaseMessage *baseMessage = inMessages[index];
        if (baseMessage.messageId == message.messageId) {
            NSUInteger previousIndex = NSNotFound;
            if (index > 0) {
                previousIndex = index - 1;
            }
            return [SBSMIndex indexOfObject:index indexOfPreviousObject:previousIndex];
        }
        else if (baseMessage.createdAt < message.createdAt) {
            NSUInteger previousIndex = NSNotFound;
            if (index > 0) {
                previousIndex = index - 1;;
            }
            return [SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:previousIndex];
        }
        
        if (reverse) {
            index--;
        }
        else {
            index++;
        }
    }
    
    return [SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:(inMessages.count - 1)];
}

+ (NSArray<SBSMIndex *> *)indexesOfMessages:(NSArray<SBDBaseMessage *> *)messages inMessages:(NSArray<SBDBaseMessage *> *)inMessages {
    if (messages == nil) {
        return @[];
    }
    
    NSComparisonResult (^sortDescription)(SBDBaseMessage *, SBDBaseMessage *) = ^NSComparisonResult(SBDBaseMessage *message1, SBDBaseMessage *message2) {
        if (message1.createdAt < message2.createdAt) {
            return NSOrderedAscending;
        }
        else return NSOrderedDescending;
    };
    
    NSComparisonResult sort = sortDescription(inMessages.firstObject, inMessages.lastObject);
    
    NSUInteger index = 0;
    NSMutableArray<SBSMIndex *> *indexes = [NSMutableArray array];
    for (SBDBaseMessage *message in messages) {
        BOOL found = NO;
        while (index < inMessages.count) {
            SBDBaseMessage *baseMessage = inMessages[index];
            if (baseMessage.messageId == message.messageId) {
                NSUInteger previousIndex = NSNotFound;
                if (index > 0) {
                    previousIndex = index - 1;
                }
                found = YES;
                [indexes addObject:[SBSMIndex indexOfObject:index indexOfPreviousObject:previousIndex]];
                break;
            }
            
            if (sort != sortDescription(message, baseMessage)) {
                NSUInteger previousIndex = NSNotFound;
                if (index > 0) {
                    previousIndex = index - 1;
                }
                found = YES;
                [indexes addObject:[SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:previousIndex]];
                break;
            }
            
            index++;
        }
        
        if (!found) {
            [indexes addObject:[SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:index]];
        }
        
        index++;
    }
    
    return [indexes copy];
}

+ (SBSMIndex *)indexOfChannel:(SBDGroupChannel *)channel inChannels:(NSArray<SBDGroupChannel *> *)inChannels sortDescription:(NSComparisonResult (^)(SBDGroupChannel *, SBDGroupChannel *))sortDescription {
    if (channel == nil || inChannels.count == 0) {
        return [[SBSMIndex alloc] init];
    }
    
    NSComparisonResult sort = sortDescription(inChannels.firstObject, inChannels.lastObject);
    
    NSUInteger index = 0;
    while (index < inChannels.count) {
        SBDGroupChannel *baseChannel = inChannels[index++];
        if ([channel.channelUrl isEqualToString:baseChannel.channelUrl]) {
            NSUInteger previousIndex = NSNotFound;
            if (index > 0) {
                previousIndex = index - 1;
            }
            return [SBSMIndex indexOfObject:index indexOfPreviousObject:previousIndex];
        }
        
        if (sortDescription(channel, baseChannel) != sort) {
            NSUInteger previousIndex = NSNotFound;
            if (index > 0) {
                previousIndex = index - 1;
            }
            return [SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:previousIndex];
        }
    }
    
    return [SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:(inChannels.count - 1)];
}

+ (NSArray<SBSMIndex *> *)indexesOfChannels:(NSArray<SBDGroupChannel *> *)channels inChannels:(NSArray<SBDGroupChannel *> *)inChannels sortDescription:(SBSMChannelComparison)sortDescription {
    if (channels == nil) {
        return @[];
    }
    
    NSComparisonResult sort = sortDescription(inChannels.firstObject, inChannels.lastObject);
    
    NSUInteger index = 0;
    NSMutableArray<SBSMIndex *> *indexes = [NSMutableArray array];
    for (SBDGroupChannel *channel in channels) {
        BOOL found = NO;
        while (index < channels.count) {
            SBDGroupChannel *baseChannel = inChannels[index];
            if ([baseChannel.channelUrl isEqualToString:channel.channelUrl]) {
                NSUInteger previousIndex = NSNotFound;
                if (index > 0) {
                    previousIndex = index - 1;
                }
                found = YES;
                [indexes addObject:[SBSMIndex indexOfObject:index indexOfPreviousObject:previousIndex]];
                break;
            }
            
            if (sort != sortDescription(channel, baseChannel)) {
                NSUInteger previousIndex = NSNotFound;
                if (index > 0) {
                    previousIndex = index - 1;;
                }
                found = YES;
                [indexes addObject:[SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:previousIndex]];
                break;
            }
        }
        
        if (!found) {
            [indexes addObject:[SBSMIndex indexOfObject:NSNotFound indexOfPreviousObject:index]];
        }
    }
    
    return [indexes copy];
}

+ (SBSMIndex *)indexOfMessageId:(long long)messageId ofMessages:(NSArray<SBDBaseMessage *> *)messages {
    if (messages.count == 0) {
        return [[SBSMIndex alloc] init];
    }
    
    NSUInteger index = 0;
    while (index < messages.count) {
        SBDBaseMessage *message = messages[index++];
        if (messageId != 0 && message.messageId == messageId) {
            NSUInteger indexOfPrevious = NSNotFound;
            if (index > 0) {
                indexOfPrevious = index - 1;
            }
            return [SBSMIndex indexOfObject:index indexOfPreviousObject:indexOfPrevious];
        }
    }
    
    return [[SBSMIndex alloc] init];
}

+ (SBSMIndex *)indexOfChannelUrl:(NSString *)channelUrl ofChannels:(NSArray<SBDBaseChannel *> *)channels {
    if (channels.count == 0) {
        return [[SBSMIndex alloc] init];
    }
    
    NSUInteger index = 0;
    while (index < channels.count) {
        SBDBaseChannel *channel = channels[index++];
        if ([channel.channelUrl isEqualToString:channelUrl]) {
            NSUInteger indexOfPrevious = NSNotFound;
            if (index > 0) {
                indexOfPrevious = index - 1;
            }
            return [SBSMIndex indexOfObject:index indexOfPreviousObject:indexOfPrevious];
        }
    }
    
    return [[SBSMIndex alloc] init];
}

@end
