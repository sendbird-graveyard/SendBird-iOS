//
//  CreateGroupChannelSelectOptionViewController.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@protocol CreateGroupChannelSelectOptionViewControllerDelegate <NSObject>

- (void)didFinishCreatingGroupChannel:(SBDGroupChannel *)channel viewController:(UIViewController *)vc;

@end

@interface CreateGroupChannelSelectOptionViewController : UIViewController

@property (strong, nonatomic) NSArray *selectedUser;
@property (weak, nonatomic) id<CreateGroupChannelSelectOptionViewControllerDelegate> delegate;

@end
