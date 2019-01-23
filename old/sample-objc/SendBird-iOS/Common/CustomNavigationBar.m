//
//  CustomNavigationBar.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 9/25/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending) {
        for (UIView *subview in self.subviews) {
            NSString *stringFromClass = NSStringFromClass([subview class]);
            if ([stringFromClass containsString:@"UIBarBackground"]) {
                subview.frame = self.bounds;
            }
            else if ([stringFromClass containsString:@"BarContentView"]) {
                [subview setFrame:CGRectMake(subview.frame.origin.x, 24, subview.frame.size.width, self.bounds.size.height - 24)];
            }
        }
    }
}

@end
