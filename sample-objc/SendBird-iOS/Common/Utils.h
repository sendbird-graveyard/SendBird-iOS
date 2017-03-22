//
//  Utils.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface Utils : NSObject

+ (nullable UIImage *)imageFromColor:(UIColor * _Nonnull)color;
+ (nullable NSAttributedString *)generateNavigationTitle:(NSString * _Nonnull)mainTitle subTitle:(NSString * _Nullable)subTitle;
+ (void)dumpMessages:(NSArray<SBDBaseMessage *> * _Nonnull)messages channelUrl:(NSString * _Nonnull)channelUrl;
+ (void)dumpChannels:(NSArray<SBDBaseChannel *> * _Nonnull)channels;

+ (nullable NSArray<SBDBaseMessage *> *)loadMessagesInChannel:(NSString * _Nonnull)channelUrl;
+ (nullable NSArray<SBDGroupChannel *> *)loadGroupChannels;
@end
