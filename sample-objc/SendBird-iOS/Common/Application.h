//
//  Application.h
//  SendBird-iOS
//
//  Created by sendbird-young on 2018. 4. 13..
//  Copyright © 2018년 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Application : NSObject

+ (BOOL)canOpenURL:(nonnull NSURL *)url;
+ (void)openURL:(nonnull NSURL *)url;
+ (void)openURL:(nonnull NSURL *)url
        options:(nullable NSDictionary <NSString *, id> *)options
completionHandler:(nullable void (^)(BOOL success))completionHandler;

@end
