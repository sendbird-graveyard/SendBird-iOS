//
//  ViewController.m
//  SendBirdSampleUI
//
//  Created by SendBird Developers on 12/30/15.
//  Copyright © 2015 SENDBIRD.COM. All rights reserved.
//

#import "ViewController.h"
#import "ChattingTableViewController.h"
#import "MessagingTableViewController.h"

@interface ViewController ()<UITextFieldDelegate>

@end

@implementation ViewController {
    NSString *messagingUserName;
    NSString *messagingUserId;
    NSString *messagingTargetUserId;
    BOOL startMessagingFromOpenChat;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self initViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *) imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void) initViews
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_sendbird_img_bg_default.jpg"]];
    [self.backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.backgroundImageView setClipsToBounds:YES];
    [self.view addSubview:self.backgroundImageView];
    
    // SendBird Logo
    self.sendbirdLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"_sendbird_icon_sendbird"]];
    [self.sendbirdLogoImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.sendbirdLogoImageView];
    
    // SendBird Label
    NSLog(@"Version: %@", [SendBird VERSION]);
    self.sendbirdLabel = [[UILabel alloc] init];
    [self.sendbirdLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdLabel setText:[NSString stringWithFormat:@"SendBird v%@", [SendBird VERSION]]];
    [self.sendbirdLabel setTextColor:[UIColor whiteColor]];
    [self.sendbirdLabel setFont:[UIFont boldSystemFontOfSize:28.0]];
    [self.sendbirdLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:28]];
    [self.view addSubview:self.sendbirdLabel];
    [self.sendbirdLabel setHidden:YES];
    
    // SendBird User Nickname Label
    self.sendbirdUserNicknameLabel = [[UILabel alloc] init];
    [self.sendbirdUserNicknameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdUserNicknameLabel setText:@"Enter your nickname."];
    [self.sendbirdUserNicknameLabel setTextColor:[UIColor whiteColor]];
    [self.sendbirdUserNicknameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:self.sendbirdUserNicknameLabel];
    
    // SendBird User Nickname
    self.sendbirdUserNicknameTextField = [[UITextField alloc] init];
    [self.sendbirdUserNicknameTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdUserNicknameTextField setBackground:[self imageFromColor:UIColorFromRGB(0xE8EAF6)]];
    [self.sendbirdUserNicknameTextField setClipsToBounds:YES];
    [[self.sendbirdUserNicknameTextField layer] setCornerRadius:4];
    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    UIView *rightPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    self.sendbirdUserNicknameTextField.leftView = leftPaddingView;
    self.sendbirdUserNicknameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.sendbirdUserNicknameTextField.rightView = rightPaddingView;
    self.sendbirdUserNicknameTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.sendbirdUserNicknameTextField setPlaceholder:@"Nickname."];
    [self.sendbirdUserNicknameTextField setFont:[UIFont systemFontOfSize:16]];
    [self.sendbirdUserNicknameTextField setReturnKeyType:UIReturnKeyDone];
    [self.sendbirdUserNicknameTextField setDelegate:self];
    
    // Set Default User Nickname
    NSString *USER_ID = [SendBirdUtils deviceUniqueID];
    NSString *USER_NAME = [NSString stringWithFormat:@"User-%@", [USER_ID substringToIndex:5]];
    [self.sendbirdUserNicknameTextField setText:USER_NAME];
    
    [self.view addSubview:self.sendbirdUserNicknameTextField];
    
    // Start Open Chat Button
    self.sendbirdStartOpenChatButton = [[UIButton alloc] init];
    [self.sendbirdStartOpenChatButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdStartOpenChatButton setBackgroundImage:[self imageFromColor:UIColorFromRGB(0xAB47BC)] forState:UIControlStateNormal];
    [self.sendbirdStartOpenChatButton setClipsToBounds:YES];
    [[self.sendbirdStartOpenChatButton layer] setCornerRadius:4];
    [self.sendbirdStartOpenChatButton addTarget:self action:@selector(clickSendBirdStartOpenChatButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendbirdStartOpenChatButton setTitle:@"Open Chat" forState:UIControlStateNormal];
    [self.sendbirdStartOpenChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendbirdStartOpenChatButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:self.sendbirdStartOpenChatButton];
    
    // Start Messaging Button
    self.sendbirdStartMessaging = [[UIButton alloc] init];
    [self.sendbirdStartMessaging setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdStartMessaging setBackgroundImage:[self imageFromColor:UIColorFromRGB(0xAB47BC)] forState:UIControlStateNormal];
    [self.sendbirdStartMessaging setClipsToBounds:YES];
    [[self.sendbirdStartMessaging layer] setCornerRadius:4];
    [self.sendbirdStartMessaging addTarget:self action:@selector(clickSendBirdStartMessagingButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendbirdStartMessaging setTitle:@"Messaging" forState:UIControlStateNormal];
    [self.sendbirdStartMessaging setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendbirdStartMessaging.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:self.sendbirdStartMessaging];

    // Member List Button
    self.sendbirdMemberListButton = [[UIButton alloc] init];
    [self.sendbirdMemberListButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdMemberListButton setBackgroundImage:[self imageFromColor:UIColorFromRGB(0xAB47BC)] forState:UIControlStateNormal];
    [self.sendbirdMemberListButton setClipsToBounds:YES];
    [[self.sendbirdMemberListButton layer] setCornerRadius:4];
    [self.sendbirdMemberListButton addTarget:self action:@selector(clickSendBirdMemberListButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendbirdMemberListButton setTitle:@"Start Messaging" forState:UIControlStateNormal];
    [self.sendbirdMemberListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendbirdMemberListButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.sendbirdMemberListButton setHidden:YES];
    [self.view addSubview:self.sendbirdMemberListButton];
    
    // Messaging Channel List Button
    self.sendbirdMessagingChannelListButton = [[UIButton alloc] init];
    [self.sendbirdMessagingChannelListButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdMessagingChannelListButton setBackgroundImage:[self imageFromColor:UIColorFromRGB(0xAB47BC)] forState:UIControlStateNormal];
    [self.sendbirdMessagingChannelListButton setClipsToBounds:YES];
    [[self.sendbirdMessagingChannelListButton layer] setCornerRadius:4];
    [self.sendbirdMessagingChannelListButton addTarget:self action:@selector(clickSendBirdMessagingChannelListButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendbirdMessagingChannelListButton setTitle:@"Messaging Channel List" forState:UIControlStateNormal];
    [self.sendbirdMessagingChannelListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendbirdMessagingChannelListButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.sendbirdMessagingChannelListButton setHidden:YES];
    [self.view addSubview:self.sendbirdMessagingChannelListButton];
    
    // Back From Messaging Button
    self.sendbirdBackFromMessaging = [[UIButton alloc] init];
    [self.sendbirdBackFromMessaging setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendbirdBackFromMessaging setBackgroundImage:[self imageFromColor:UIColorFromRGB(0x43A047)] forState:UIControlStateNormal];
    [self.sendbirdBackFromMessaging setClipsToBounds:YES];
    [[self.sendbirdBackFromMessaging layer] setCornerRadius:4];
    [self.sendbirdBackFromMessaging addTarget:self action:@selector(clickSendBirdBackFromMessaging:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendbirdBackFromMessaging setTitle:@"Back" forState:UIControlStateNormal];
    [self.sendbirdBackFromMessaging setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendbirdBackFromMessaging.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.sendbirdBackFromMessaging setHidden:YES];
    [self.view addSubview:self.sendbirdBackFromMessaging];

    // Background Image
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1 constant:0]];
    
    // SendBird Logo
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdLogoImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdLogoImageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1 constant:48]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdLogoImageView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:90]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdLogoImageView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:90]];
    
    // SendBird Label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdLogoImageView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    
    // SendBird User Nickname Label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];
    
    
    // SendBird User Nickname TextField
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameTextField
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameTextField
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdUserNicknameLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:4]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameTextField
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdUserNicknameTextField
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];
    
    // SendBird Start Open Chat Button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartOpenChatButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartOpenChatButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdUserNicknameTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:40]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartOpenChatButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartOpenChatButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];
    
    // SendBird Start Messaging Button.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartMessaging
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartMessaging
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdStartOpenChatButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:12]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartMessaging
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdStartMessaging
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];

    // SendBird Start Open Chat Button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMemberListButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMemberListButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdUserNicknameTextField
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:40]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMemberListButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMemberListButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];

    // SendBird Messaging Channel List.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMessagingChannelListButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMessagingChannelListButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdMemberListButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:12]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMessagingChannelListButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdMessagingChannelListButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];
    
    // Back From Messaging Button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdBackFromMessaging
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdBackFromMessaging
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.sendbirdMessagingChannelListButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1 constant:12]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdBackFromMessaging
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:220]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.sendbirdBackFromMessaging
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1 constant:36]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMessagingWithUser:) name:@"open_messaging" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (startMessagingFromOpenChat == YES) {
        MessagingTableViewController *viewController = [[MessagingTableViewController alloc] init];
        
        [viewController setViewMode:kMessagingViewMode];
        [viewController initChannelTitle];
        [viewController setChannelUrl:@""];
        [viewController setUserName:messagingUserName];
        [viewController setUserId:messagingUserId];
        [viewController setTargetUserId:messagingTargetUserId];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navigationController animated:YES completion: nil];
    }
    
    startMessagingFromOpenChat = NO;
}

- (void)startMessagingWithUser:(NSNotification *)obj {
    messagingTargetUserId = (NSString *)[obj object];
    startMessagingFromOpenChat = YES;
}

- (void)clickSendBirdStartOpenChatButton:(id)sender
{
    if ([[self.sendbirdUserNicknameTextField text] length] > 0) {
        [self startSendBirdWithUserName:[self.sendbirdUserNicknameTextField text] andChatMode:kChatModeChatting andViewMode:(int)kChannelListViewMode];
    }
}

- (void)clickSendBirdStartMessagingButton:(id)sender
{
    [self.sendbirdStartOpenChatButton setHidden:YES];
    [self.sendbirdStartMessaging setHidden:YES];
    [self.sendbirdMemberListButton setHidden:NO];
    [self.sendbirdMessagingChannelListButton setHidden:NO];
    [self.sendbirdBackFromMessaging setHidden:NO];
}

- (void)clickSendBirdMemberListButton:(id)sender
{
    if ([[self.sendbirdUserNicknameTextField text] length] > 0) {
        [self startSendBirdWithUserName:[self.sendbirdUserNicknameTextField text] andChatMode:kChatModeMessaging andViewMode:(int)kMessagingMemberViewMode];
    }
}

- (void)clickSendBirdMessagingChannelListButton:(id)sender
{
    if ([[self.sendbirdUserNicknameTextField text] length] > 0) {
        [self startSendBirdWithUserName:[self.sendbirdUserNicknameTextField text] andChatMode:kChatModeMessaging andViewMode:(int)kMessagingChannelListViewMode];
    }
}

///
- (void)clickSendBirdBackFromMessaging:(id)sender
{
    [self.sendbirdStartOpenChatButton setHidden:NO];
    [self.sendbirdStartMessaging setHidden:NO];
    [self.sendbirdMemberListButton setHidden:YES];
    [self.sendbirdMessagingChannelListButton setHidden:YES];
    [self.sendbirdBackFromMessaging setHidden:YES];
}

- (void) startSendBirdWithUserName:(NSString *)userName andChatMode:(int)chatMode andViewMode:(int)viewMode
{
    NSString *USER_ID = [SendBirdUtils deviceUniqueID];
    NSString *USER_NAME = userName;
    
    messagingUserName = USER_NAME;
    messagingUserId = USER_ID;
    
    if (chatMode == kChatModeChatting) {
        ChattingTableViewController *viewController = [[ChattingTableViewController alloc] init];

        [viewController setViewMode:viewMode];
        [viewController initChannelTitle];
        [viewController setUserName:USER_NAME];
        [viewController setUserId:USER_ID];
        
        [self.navigationController pushViewController:viewController animated:NO];
    }
    else if (chatMode == kChatModeMessaging) {
        MessagingTableViewController *viewController = [[MessagingTableViewController alloc] init];
        
        [viewController setViewMode:viewMode];
        [viewController initChannelTitle];
        [viewController setUserName:USER_NAME];
        [viewController setUserId:USER_ID];
        
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
