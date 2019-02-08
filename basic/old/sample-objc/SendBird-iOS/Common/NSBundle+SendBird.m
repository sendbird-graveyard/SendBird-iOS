//
//  NSBundle+SendBird.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/18/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "NSBundle+SendBird.h"
#import "ViewController.h"

@implementation NSBundle (SendBird)

+ (NSBundle *)sbBundle
{
    return [NSBundle bundleForClass:[ViewController class]];
}

+ (NSBundle *)sbResourceBundle
{
    NSString *bundleResourcePath = [NSBundle sbBundle].resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:@"SendBird-iOS.bundle"];
    return [NSBundle bundleWithPath:assetPath];
}

+ (NSString *)sbLocalizedStringForKey:(NSString *)key
{
    return NSLocalizedStringFromTableInBundle(key, @"Localizable", [NSBundle sbResourceBundle], nil);
}

@end
