//
//  MessagingChannelListViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/26/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagingChannelListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (void)setUserID:(NSString *)aUserID userName:(NSString *)aUserName;

@end
