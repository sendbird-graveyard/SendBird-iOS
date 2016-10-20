//
//  GroupChannelListViewController.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import <SendBirdSDK/SendBirdSDK.h>

#import "CreateGroupChannelUserListViewController.h"

@interface GroupChannelListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, CreateGroupChannelUserListViewControllerDelegate, SBDChannelDelegate, SBDConnectionDelegate>

@end
