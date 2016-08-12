//
//  ViewController.h
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 12/30/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController

@property UIImageView *sendbirdLogoImageView;
@property UILabel *sendbirdLabel;

@property UIImageView *backgroundImageView;
@property UIButton *sendbirdStartOpenChatButton;
@property UIButton *sendbirdStartMessaging;
@property UIButton *sendbirdMemberListButton;
@property UIButton *sendbirdMessagingChannelList;
@property UIButton *sendbirdBackFromMessaging;


@property UIButton *sendbirdChannelListButton;
@property UIButton *sendbirdLobbyMemberListButton;
@property UIButton *sendbirdMessagingChannelListButton;
@property UILabel *sendbirdUserNicknameLabel;
@property UITextField *sendbirdUserNicknameTextField;

- (UIImage *) imageFromColor:(UIColor *)color;

@end

