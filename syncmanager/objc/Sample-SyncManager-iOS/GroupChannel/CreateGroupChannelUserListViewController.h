//
//  CreateGroupChannelUserListViewController.h
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/21/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "CreateGroupChannelSelectOptionViewController.h"

@protocol CreateGroupChannelUserListViewControllerDelegate <NSObject>

- (void)presentGroupChannel:(nonnull SBDGroupChannel *)channel onViewController:(nonnull UIViewController *)parentViewController;

@end

@interface CreateGroupChannelUserListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, CreateGroupChannelSelectOptionViewControllerDelegate>

@property (weak, nonatomic, nullable) id<CreateGroupChannelUserListViewControllerDelegate> delegate;

@property (atomic) int userSelectionMode; // 0: Create channel, 1: Invite user
@property (strong, nonatomic, nullable) SBDGroupChannel *groupChannel;

@end
