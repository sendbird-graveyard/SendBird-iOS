//
//  Utils.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "Utils.h"
#import "Constants.h"
#import "NSString+URLEncode.h"

@implementation Utils

+ (nullable UIImage *)imageFromColor:(UIColor * _Nonnull)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (nullable NSAttributedString *)generateNavigationTitle:(NSString * _Nonnull)mainTitle subTitle:(NSString * _Nullable)subTitle {
    NSDictionary *mainTitleAttribute;
    NSDictionary *subTitleAttribute = nil;
    if (subTitle == nil || subTitle.length == 0) {
        mainTitleAttribute = @{
                             NSFontAttributeName: [Constants navigationBarTitleFont],
                             NSForegroundColorAttributeName: [UIColor blackColor]
                             };
    }
    else {
        mainTitleAttribute = @{
                               NSFontAttributeName: [Constants navigationBarTitleFont],
                               NSForegroundColorAttributeName: [UIColor blackColor]
                               };
        subTitleAttribute = @{
                              NSFontAttributeName: [Constants navigationBarSubTitleFont],
                              NSForegroundColorAttributeName: [Constants navigationBarSubTitleColor]
                              };
    }
    
    NSMutableAttributedString *fullTitle = nil;
    if (subTitle == nil || subTitle.length == 0) {
        fullTitle = [[NSMutableAttributedString alloc] initWithString:mainTitle];
        [fullTitle addAttributes:mainTitleAttribute range:NSMakeRange(0, [mainTitle length])];
    }
    else {
        fullTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", mainTitle, subTitle]];
        
        [fullTitle addAttributes:mainTitleAttribute range:NSMakeRange(0, [mainTitle length])];
        [fullTitle addAttributes:subTitleAttribute range:NSMakeRange([mainTitle length] + 1, [subTitle length])];
    }
    
    return fullTitle;
}

+ (void)dumpMessages:(NSArray<SBDBaseMessage *> * _Nonnull)messages resendableMessages:(NSDictionary<NSString *, SBDBaseMessage *> * _Nullable)resendableMessages resendableFileData:(NSDictionary<NSString *, NSDictionary<NSString *, NSObject *> *> * _Nullable)resendableFileData preSendMessages:(NSDictionary<NSString *, SBDBaseMessage *> * _Nullable)preSendMessages channelUrl:(NSString * _Nonnull)channelUrl{
    // Serialize messages
    NSUInteger startIndex = 0;
    
    if (messages.count == 0) {
        return;
    }
    
    if (messages.count > 100) {
        startIndex = messages.count - 100;
    }
    
    NSMutableArray<NSString *> *serializedMessages = [[NSMutableArray alloc] init];
    for (; startIndex < messages.count; startIndex++) {
        NSString *requestId = nil;
        if ([messages[startIndex] isKindOfClass:[SBDUserMessage class]]) {
            requestId = ((SBDUserMessage *)messages[startIndex]).requestId;
        }
        else if ([messages[startIndex] isKindOfClass:[SBDFileMessage class]]) {
            requestId = ((SBDFileMessage *)messages[startIndex]).requestId;
        }
        
        if (requestId != nil && requestId.length > 0) {
            if (resendableMessages[requestId] != nil) {
                continue;
            }
            
            if (preSendMessages[requestId] != nil) {
                continue;
            }
            
            if (resendableFileData[requestId] != nil) {
                continue;
            }
        }
        
        NSData *messageData = [messages[startIndex] serialize];
        NSString *messageString = [messageData base64EncodedStringWithOptions:0];
        [serializedMessages addObject:messageString];
    }
    
    NSString *dumpedMessages = [serializedMessages componentsJoinedByString:@"\n"];
    NSString *dumpedMessagesHash = [[self class] sha256:dumpedMessages];
    
    // Save messages to temp file.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appIdDirectory = [documentsDirectory stringByAppendingPathComponent:[SBDMain getApplicationId]];
    
    NSString *uniqueTempFileNamePrefix = [[NSUUID UUID] UUIDString];
    NSString *tempMessageDumpFileName = [NSString stringWithFormat:@"%@.data", uniqueTempFileNamePrefix];
    NSString *tempMessageHashFileName = [NSString stringWithFormat:@"%@.hash", uniqueTempFileNamePrefix];
    
    NSString *tempMessageDumpFilePath = [appIdDirectory stringByAppendingPathComponent:tempMessageDumpFileName];
    NSString *tempMessageHashFilePath = [appIdDirectory stringByAppendingPathComponent:tempMessageHashFileName];
    
    NSError *errorCreateDirectory = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:appIdDirectory] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:appIdDirectory withIntermediateDirectories:NO attributes:nil error:&errorCreateDirectory];
    }
    
    if (errorCreateDirectory != nil) {
        return;
    }
    
    NSString *messageFileNamePrefix = [[self class] sha256:[NSString stringWithFormat:@"%@_%@", [[SBDMain getCurrentUser].userId urlencoding], channelUrl]];
    NSString *messageDumpFileName = [NSString stringWithFormat:@"%@.data", messageFileNamePrefix];
    NSString *messageHashFileName = [NSString stringWithFormat:@"%@.hash", messageFileNamePrefix];
    
    NSString *messageDumpFilePath = [appIdDirectory stringByAppendingPathComponent:messageDumpFileName];
    NSString *messageHashFilePath = [appIdDirectory stringByAppendingPathComponent:messageHashFileName];
    
    // Check hash.
    NSString *previousHash;
    if (![[NSFileManager defaultManager] fileExistsAtPath:messageDumpFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:messageDumpFilePath contents:nil attributes:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:messageHashFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:messageHashFilePath contents:nil attributes:nil];
    }
    else {
        previousHash = [NSString stringWithContentsOfFile:messageHashFilePath encoding:NSUTF8StringEncoding error:nil];
    }
    
    if (previousHash != nil && [previousHash isEqualToString:dumpedMessagesHash]) {
        return;
    }
    
    // Write temp file.
    NSError *errorDump = nil;
    NSError *errorHash = nil;
    [dumpedMessages writeToFile:tempMessageDumpFilePath atomically:NO encoding:NSUTF8StringEncoding error:&errorDump];
    [dumpedMessagesHash writeToFile:tempMessageHashFilePath atomically:NO encoding:NSUTF8StringEncoding error:&errorHash];
    
    // Move temp to real file.
    if (errorDump == nil && errorHash == nil) {
        NSError *errorMoveDumpFile;
        NSError *errorMoveHashFile;
        
        [[NSFileManager defaultManager] removeItemAtPath:messageDumpFilePath error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:tempMessageDumpFilePath toPath:messageDumpFilePath error:&errorMoveDumpFile];
        
        [[NSFileManager defaultManager] removeItemAtPath:messageHashFilePath error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:tempMessageHashFilePath toPath:messageHashFilePath error:&errorMoveHashFile];
        
        if (errorMoveDumpFile != nil || errorMoveHashFile != nil) {
            [[NSFileManager defaultManager] removeItemAtPath:tempMessageDumpFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:tempMessageHashFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:messageDumpFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:messageHashFilePath error:nil];
        }
    }
}

+ (nullable NSArray<SBDBaseMessage *> *)loadMessagesInChannel:(NSString * _Nonnull)channelUrl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appIdDirectory = [documentsDirectory stringByAppendingPathComponent:[SBDMain getApplicationId]];
    NSString *messageFileNamePrefix = [[self class] sha256:[NSString stringWithFormat:@"%@_%@", [[SBDMain getCurrentUser].userId urlencoding], channelUrl]];
    NSString *dumpFileName = [NSString stringWithFormat:@"%@.data", messageFileNamePrefix];
    NSString *dumpFilePath = [appIdDirectory stringByAppendingPathComponent:dumpFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dumpFilePath]) {
        return nil;
    }
    
    NSError *errorReadDump;
    NSString *messageDump = [NSString stringWithContentsOfFile:dumpFilePath encoding:NSUTF8StringEncoding error:&errorReadDump];
    
    if (messageDump.length > 0) {
        NSArray *loadMessages = [messageDump componentsSeparatedByString:@"\n"];
        
        if (loadMessages.count > 0) {
            NSMutableArray<SBDBaseMessage *> *messages = [[NSMutableArray alloc] init];
            for (NSString *msgString in loadMessages) {
                NSData *msgData = [[NSData alloc] initWithBase64EncodedString:msgString options:0];

                
                SBDBaseMessage *message = [SBDBaseMessage buildFromSerializedData:msgData];
                [messages addObject:message];
            }
            
            return messages;
        }
    }
    
    return nil;
}

+ (void)dumpChannels:(NSArray<SBDBaseChannel *> * _Nonnull)channels {
    // Serialize channels
    NSUInteger startIndex = 0;
    
    if (channels.count == 0) {
        return;
    }
    
    if (channels.count > 100) {
        startIndex = channels.count - 100;
    }
    
    NSMutableArray<NSString *> *serializedChannels = [[NSMutableArray alloc] init];
    for (; startIndex < channels.count; startIndex++) {
        NSData *channelData = [channels[startIndex] serialize];
        NSString *channelString = [channelData base64EncodedStringWithOptions:0];
        [serializedChannels addObject:channelString];
    }
    
    NSString *dumpedChannels = [serializedChannels componentsJoinedByString:@"\n"];
    NSString *dumpedChannelsHash = [[self class] sha256:dumpedChannels];
    
    // Save channels to temp file.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appIdDirectory = [documentsDirectory stringByAppendingPathComponent:[SBDMain getApplicationId]];
    
    NSString *uniqueTempFileNamePrefix = [[NSUUID UUID] UUIDString];
    NSString *tempChannelDumpFileName = [NSString stringWithFormat:@"%@_channellist.data", uniqueTempFileNamePrefix];
    NSString *tempChannelHashFileName = [NSString stringWithFormat:@"%@_channellist.hash", uniqueTempFileNamePrefix];
    
    NSString *tempChannelDumpFilePath = [appIdDirectory stringByAppendingPathComponent:tempChannelDumpFileName];
    NSString *tempChannelHashFilePath = [appIdDirectory stringByAppendingPathComponent:tempChannelHashFileName];
    
    NSError *errorCreateDirectory = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:appIdDirectory] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:appIdDirectory withIntermediateDirectories:NO attributes:nil error:&errorCreateDirectory];
    }
    
    if (errorCreateDirectory != nil) {
        return;
    }
    
    NSString *channelFileNamePrefix = [NSString stringWithFormat:@"%@_channellist", [[self class] sha256:[[SBDMain getCurrentUser].userId urlencoding]]];
    NSString *channelDumpFileName = [NSString stringWithFormat:@"%@.data", channelFileNamePrefix];
    NSString *channelHashFileName = [NSString stringWithFormat:@"%@.hash", channelFileNamePrefix];
    
    NSString *channelDumpFilePath = [appIdDirectory stringByAppendingPathComponent:channelDumpFileName];
    NSString *channelHashFilePath = [appIdDirectory stringByAppendingPathComponent:channelHashFileName];
    
    // Check hash.
    NSString *previousHash;
    if (![[NSFileManager defaultManager] fileExistsAtPath:channelDumpFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:channelDumpFilePath contents:nil attributes:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:channelHashFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:channelHashFilePath contents:nil attributes:nil];
    }
    else {
        previousHash = [NSString stringWithContentsOfFile:channelHashFilePath encoding:NSUTF8StringEncoding error:nil];
    }
    
    if (previousHash != nil && [previousHash isEqualToString:dumpedChannelsHash]) {
        return;
    }
    
    // Write temp file.
    NSError *errorDump = nil;
    NSError *errorHash = nil;
    [dumpedChannels writeToFile:tempChannelDumpFilePath atomically:NO encoding:NSUTF8StringEncoding error:&errorDump];
    [dumpedChannelsHash writeToFile:tempChannelHashFilePath atomically:NO encoding:NSUTF8StringEncoding error:&errorHash];
    
    // Move temp to real file.
    if (errorDump == nil && errorHash == nil) {
        NSError *errorMoveDumpFile;
        NSError *errorMoveHashFile;
        
        [[NSFileManager defaultManager] removeItemAtPath:channelDumpFilePath error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:tempChannelDumpFilePath toPath:channelDumpFilePath error:&errorMoveDumpFile];
        
        [[NSFileManager defaultManager] removeItemAtPath:channelHashFilePath error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:tempChannelHashFilePath toPath:channelHashFilePath error:&errorMoveHashFile];
        
        if (errorMoveDumpFile != nil || errorMoveHashFile != nil) {
            [[NSFileManager defaultManager] removeItemAtPath:tempChannelDumpFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:tempChannelHashFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:channelDumpFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:channelHashFilePath error:nil];
        }
    }
}

+ (nullable NSArray<SBDGroupChannel *> *)loadGroupChannels {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"User ID: %@", [SBDMain getCurrentUser].userId);
    NSString *channelFileNamePrefix = [NSString stringWithFormat:@"%@_channellist", [[self class] sha256:[[SBDMain getCurrentUser].userId urlencoding]]];
    NSString *dumpFileName = [NSString stringWithFormat:@"%@.data", channelFileNamePrefix];
    NSString *appIdDirectory = [documentsDirectory stringByAppendingPathComponent:[SBDMain getApplicationId]];
    NSString *dumpFilePath = [appIdDirectory stringByAppendingPathComponent:dumpFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dumpFilePath]) {
        return nil;
    }
    
    NSError *errorReadDump;
    NSString *channelDump = [NSString stringWithContentsOfFile:dumpFilePath encoding:NSUTF8StringEncoding error:&errorReadDump];
    
    if (channelDump.length > 0) {
        NSArray *loadChannels = [channelDump componentsSeparatedByString:@"\n"];
        
        if (loadChannels.count > 0) {
            NSMutableArray<SBDGroupChannel *> *channels = [[NSMutableArray alloc] init];
            for (NSString *channelString in loadChannels) {
                NSData *channelData = [[NSData alloc] initWithBase64EncodedString:channelString options:0];

                SBDGroupChannel *channel = [SBDGroupChannel buildFromSerializedData:channelData];
                [channels addObject:channel];
            }
            
            return channels;
        }
    }
    
    return nil;
}

+ (nonnull NSString *)sha256:(NSString * _Nonnull)src {
    const char* str = [src UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (uint32_t)strlen(str), result);
    
    NSMutableString *sha256hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [sha256hash appendFormat:@"%02x", result[i]];
    }
    
    if (sha256hash == nil) {
        return @"";
    }
    
    return sha256hash;
}

+ (nullable UIViewController *)findBestViewController:(UIViewController * _Nonnull)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [Utils findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0) {
            return [Utils findBestViewController:svc.viewControllers.lastObject];
        }
        else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0) {
            return [Utils findBestViewController:svc.topViewController];
        }
        else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0) {
            return [Utils findBestViewController:svc.selectedViewController];
        }
        else {
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

+ (bool)isIPhoneX {
    return [[UIScreen mainScreen] fixedCoordinateSpace].bounds.size.height == 812.0;
}

@end
