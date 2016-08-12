//
//  ViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/23/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<SBDConnectionDelegate, SBDChannelDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIView *firstPhaseContentView;
@property (weak, nonatomic) IBOutlet UIView *secondPhaseContentView;

@property (weak, nonatomic) IBOutlet UIButton *openChatButton;
@property (weak, nonatomic) IBOutlet UIButton *messagingButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *updateNicknameButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonnull) NSString *delegateIndetifier;

@property (atomic) BOOL loggedIn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegateIndetifier = self.description;
    [SBDMain addConnectionDelegate:self identifier:self.delegateIndetifier];
    [SBDMain addChannelDelegate:self identifier:self.delegateIndetifier];
    
    self.loggedIn = NO;
    
    [self.activityIndicatorView setHidden:YES];
    [self.firstPhaseContentView setHidden:NO];
    [self.secondPhaseContentView setHidden:YES];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_name"];
    
    [self.openChatButton setEnabled:NO];
    [self.messagingButton setEnabled:NO];
    [self.updateNicknameButton setEnabled:NO];
    
    [self.userIdTextField setText:userId];
    [self.nicknameTextField setText:userName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickLogin:(id)sender {
    if (self.loggedIn) {
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicatorView startAnimating];
        [self.userIdTextField setEnabled:YES];
        [SBDMain disconnectWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loggedIn = NO;
                [self.openChatButton setEnabled:NO];
                [self.messagingButton setEnabled:NO];
                [self.updateNicknameButton setEnabled:NO];
                [self.loginButton setTitle:@"Connect" forState:UIControlStateNormal];
                
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView setHidden:YES];
            });
        }];
    }
    else {
        [self.activityIndicatorView setHidden:NO];
        [self.activityIndicatorView startAnimating];
        [self.userIdTextField setEnabled:NO];
        [SBDMain connectWithUserId:[self.userIdTextField text] accessToken:@"" completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
            if (error == nil) {
                [SBDMain updateCurrentUserInfoWithNickname:[self.nicknameTextField text] profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"User Info Updating Error: %@", error);
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].userId forKey:@"sendbird_user_id"];
                    [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].nickname forKey:@"sendbird_user_name"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.loggedIn = YES;
                        [self.openChatButton setEnabled:YES];
                        [self.messagingButton setEnabled:YES];
                        [self.updateNicknameButton setEnabled:YES];
                        [self.loginButton setTitle:@"Disconnect" forState:UIControlStateNormal];
                        
                        [self.activityIndicatorView stopAnimating];
                        [self.activityIndicatorView setHidden:YES];
                    });
                }];
            }
            else {
                NSLog(@"Connection Error: %@", error);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.userIdTextField setEnabled:YES];
                    [self.activityIndicatorView stopAnimating];
                    [self.activityIndicatorView setHidden:YES];
                });
            }
        }];
    }
}

- (IBAction)clickUpdateNickname:(id)sender {
    [self.activityIndicatorView startAnimating];
    [self.activityIndicatorView setHidden:NO];
    [SBDMain updateCurrentUserInfoWithNickname:[self.nicknameTextField text] profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView setHidden:YES];
        
        if (error != nil) {
            NSLog(@"Updating Nickname Error: %@", error);
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[self.nicknameTextField text] forKey:@"sendbird_user_name"];
    }];
}

- (IBAction)clickOpenChat:(id)sender {
    NSString *userId = [self.userIdTextField text];
    NSString *userName = [self.nicknameTextField text];
    
    if ([userId length] == 0 || [userName length] == 0) {
        return;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"sendbird_user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"sendbird_user_name"];

        OpenChatListViewController *vc = [[OpenChatListViewController alloc] init];
//        [vc setUserID:userId userName:userName];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)clickMessaging:(id)sender { 
    NSString *userId = [self.userIdTextField text];
    NSString *userName = [self.nicknameTextField text];
    
    if ([userId length] == 0 || [userName length] == 0) {
        return;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"sendbird_user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"sendbird_user_name"];
        
        MessagingChannelListViewController *vc = [[MessagingChannelListViewController alloc] init];
        [vc setUserID:userId userName:userName];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)clickMemberList:(id)sender {
    NSString *userId = [self.userIdTextField text];
    NSString *userName = [self.nicknameTextField text];
    
    if ([userId length] == 0 || [userName length] == 0) {
        return;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"sendbird_user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"sendbird_user_name"];
        
        UserListViewController *vc = [[UserListViewController alloc] init];
//        [vc setUserID:userId userName:userName];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)clickMessagingChannelList:(id)sender {
//    NSString *userId = [self.userIdTextField text];
//    NSString *userName = [self.nicknameTextField text];
//    
//    if ([userId length] == 0 || [userName length] == 0) {
//        return;
//    }
//    else {
//        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"sendbird_user_id"];
//        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"sendbird_user_name"];
//        
//        MessagingChannelListViewController *vc = [[MessagingChannelListViewController alloc] init];
//        [vc setUserID:userId userName:userName];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}

- (IBAction)clickBack:(id)sender {
    [self.firstPhaseContentView setHidden:NO];
    [self.secondPhaseContentView setHidden:YES];
}


#pragma mark - SBDConnectionDelegate
- (void)didStartReconnection {
    NSLog(@"didStartReconnection delegate in ViewController");
}


- (void)didSucceedReconnection {
    NSLog(@"didSucceedReconnection delegate in ViewController");
}

- (void)didFailReconnection {
    NSLog(@"didFailReconnection delegate in ViewController");
}

#pragma mark - SBDChannelDelegate
- (void)didReceiveMessage:(SBDBaseChannel * _Nonnull)channel message:(SBDBaseMessage * _Nonnull)message {
    NSLog(@"didReceiveMessage:message: delegate in ViewController");
}

- (void)didUpdateReadReceipt:(SBDGroupChannel * _Nullable)channel {
    NSLog(@"didUpdateReadReceipt: delegate in ViewController");
}

- (void)didUpdateTypingStatus:(SBDGroupChannel * _Nullable)channel {
    NSLog(@"didUpdateTypingStatus: delegate in ViewController");
}

@end
