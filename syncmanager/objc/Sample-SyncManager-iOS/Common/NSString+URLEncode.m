//
//  NSString+URLEncode.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Gyeong on 7/26/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

- (NSString * _Nonnull)urlencoding {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' ||
                   thisChar == '-' ||
                   thisChar == '_' ||
                   thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@end
