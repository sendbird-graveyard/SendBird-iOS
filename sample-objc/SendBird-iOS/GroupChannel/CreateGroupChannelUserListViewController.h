//
//  CreateGroupChannelUserListViewController.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateGroupChannelSelectOptionViewController.h"

@protocol CreateGroupChannelUserListViewControllerDelegate <NSObject>

- (void)openGroupChannel:(SBDGroupChannel *)channel viewController:(UIViewController *)vc;

@end

@interface CreateGroupChannelUserListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, CreateGroupChannelSelectOptionViewControllerDelegate>

@property (weak, nonatomic) id<CreateGroupChannelUserListViewControllerDelegate> delegate;

@end
