//
//  Constants.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/17/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (UIColor *)navigationBarTitleColor {
    return [UIColor colorWithRed:(CGFloat)(128.0/255.0) green:(CGFloat)(90.0/255.0) blue:(CGFloat)(255.0/255.0) alpha:1];
}

+ (UIFont *)navigationBarTitleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
}

+ (UIColor *)textFieldLineColorNormal {
    return [UIColor colorWithRed:(CGFloat)(217.0/255.0) green:(CGFloat)(217.0/255.0) blue:(CGFloat)(217.0/255.0) alpha:1];
}

+ (UIColor *)textFieldLineColorSelected {
    return [UIColor colorWithRed:(CGFloat)(140.0/255.0) green:(CGFloat)(109.0/255.0) blue:(CGFloat)(238.0/255.0) alpha:1];
}

+ (UIFont *)nicknameFontInMessage {
    return [UIFont fontWithName:@"HelveticaNeue" size:16.0];
}

+ (UIColor *)nicknameColorInMessageNo0 {
    return [UIColor colorWithRed:(CGFloat)(45.0/255.0) green:(CGFloat)(27.0/255.0) blue:(CGFloat)(225.0/255.0) alpha:1];
}

+ (UIColor *)nicknameColorInMessageNo1 {
    return [UIColor colorWithRed:(CGFloat)(53.0/255.0) green:(CGFloat)(163.0/255.0) blue:(CGFloat)(251.0/255.0) alpha:1];
}

+ (UIColor *)nicknameColorInMessageNo2 {
    return [UIColor colorWithRed:(CGFloat)(128.0/255.0) green:(CGFloat)(90.0/255.0) blue:(CGFloat)(255.0/255.0) alpha:1];
}

+ (UIColor *)nicknameColorInMessageNo3 {
    return [UIColor colorWithRed:(CGFloat)(207.0/255.0) green:(CGFloat)(72.0/255.0) blue:(CGFloat)(251.0/255.0) alpha:1];
}

+ (UIColor *)nicknameColorInMessageNo4 {
    return [UIColor colorWithRed:(CGFloat)(226.0/255.0) green:(CGFloat)(72.0/255.0) blue:(CGFloat)(196.0/255.0) alpha:1];
}

+ (UIFont *)messageDateFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:12.0];
}

+ (UIColor *)messageDateColor {
    return [UIColor colorWithRed:(CGFloat)(142.0/255.0) green:(CGFloat)(142.0/255.0) blue:(CGFloat)(142.0/255.0) alpha:1];
}

+ (UIColor *)incomingFileImagePlaceholderColor {
    return [UIColor colorWithRed:(CGFloat)(238.0/255.0) green:(CGFloat)(241.0/255.0) blue:(CGFloat)(246.0/255.0) alpha:1];
}

+ (UIFont *)messageFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:16.0];
}

+ (UIColor *)outgoingFileImagePlaceholderColor {
    return [UIColor colorWithRed:(CGFloat)(128.0/255.0) green:(CGFloat)(90.0/255.0) blue:(CGFloat)(255.0/255.0) alpha:1];
}

+ (UIColor *)openChannelLineColorNo0 {
    return [UIColor colorWithRed:(CGFloat)(45.0/255.0) green:(CGFloat)(227.0/255.0) blue:(CGFloat)(225.0/255.0) alpha:1];
}

+ (UIColor *)openChannelLineColorNo1 {
    return [UIColor colorWithRed:(CGFloat)(53.0/255.0) green:(CGFloat)(163.0/255.0) blue:(CGFloat)(251.0/255.0) alpha:1];
}

+ (UIColor *)openChannelLineColorNo2 {
    return [UIColor colorWithRed:(CGFloat)(128.0/255.0) green:(CGFloat)(90.0/255.0) blue:(CGFloat)(255.0/255.0) alpha:1];
}

+ (UIColor *)openChannelLineColorNo3 {
    return [UIColor colorWithRed:(CGFloat)(207.0/255.0) green:(CGFloat)(72.0/255.0) blue:(CGFloat)(251.0/255.0) alpha:1];
}

+ (UIColor *)openChannelLineColorNo4 {
    return [UIColor colorWithRed:(CGFloat)(226.0/255.0) green:(CGFloat)(72.0/255.0) blue:(CGFloat)(195.0/255.0) alpha:1];
}

+ (UIColor *)leaveButtonColor {
    return [UIColor redColor];
}

+ (UIColor *)hideButtonColor {
    return [UIColor colorWithRed:(CGFloat)(116.0/255.0) green:(CGFloat)(127.0/255.0) blue:(CGFloat)(145.0/255.0) alpha:1];
}

+ (UIFont *)leaveButtonFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:18.0];
}

+ (UIFont *)hideButtonFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:18.0];
}

+ (UIFont *)distinctButtonSelected {
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
}

+ (UIFont *)distinctButtonNormal {
    return [UIFont fontWithName:@"HelveticaNeue" size:18.0];
}

+ (UIFont *)navigationBarButtonItemFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:18.0];
}

+ (UIColor *)memberOnlineTextColor {
    return [UIColor colorWithRed:41.0/255.0 green:197.0/255.0 blue:25.0/255.0 alpha:1];
}

+ (UIColor *)memberOfflineDateTextColor {
    return [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1];
}

@end
