//
//  ParticipantListViewController.h
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 7/28/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface ParticipantListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic, nullable) SBDOpenChannel *currentChannel;

@end
