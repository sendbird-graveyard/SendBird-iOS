//
//  SendBirdSDKUtils.h
//  SendBirdFramework
//
//  Created by SendBird Developers on 2015. 8. 21..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendBirdSDKUtils : NSObject

+ (NSUInteger)occurrenceCountOfCharacter:(UniChar)character inSourceString:(NSString *)source;
+ (NSString *) jsonStringWithPrettyPrint:(BOOL) prettyPrint fromDictionary:(NSDictionary *)dic;

@end
