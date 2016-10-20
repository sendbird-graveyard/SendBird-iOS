//
//  CreateOpenChannelViewController.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateOpenChannelViewControllerDelegate <NSObject>

- (void)refreshView:(UIViewController *)vc;

@end

@interface CreateOpenChannelViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) id<CreateOpenChannelViewControllerDelegate> delegate;

@end
