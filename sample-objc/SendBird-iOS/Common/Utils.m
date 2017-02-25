//
//  Utils.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "Utils.h"
#import "Constants.h"

@implementation Utils

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSAttributedString *)generateNavigationTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle {
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

@end
