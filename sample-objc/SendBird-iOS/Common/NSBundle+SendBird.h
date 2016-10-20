//
//  NSBundle+SendBird.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/18/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (SendBird)

+ (NSBundle *)sbBundle;
+ (NSBundle *)sbResourceBundle;
+ (NSString *)sbLocalizedStringForKey:(NSString *)key;

@end
