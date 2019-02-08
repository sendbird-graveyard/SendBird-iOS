//
//  BannedUserListViewController.h
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/4/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface BlockedUserListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) SBDBaseChannel *channel;

@end
