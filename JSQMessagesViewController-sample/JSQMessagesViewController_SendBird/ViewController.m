//
//  ViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Kyung on 4/23/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIView *firstPhaseContentView;
@property (weak, nonatomic) IBOutlet UIView *secondPhaseContentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.firstPhaseContentView setHidden:NO];
    [self.secondPhaseContentView setHidden:YES];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_name"];
    
    [self.userIdTextField setText:userId];
    [self.nicknameTextField setText:userName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [vc setUserID:userId userName:userName];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}

- (IBAction)clickMessaging:(id)sender {
    [self.firstPhaseContentView setHidden:YES];
    [self.secondPhaseContentView setHidden:NO];
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
        
        MemberListViewController *vc = [[MemberListViewController alloc] init];
        [vc setUserID:userId userName:userName];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}

- (IBAction)clickMessagingChannelList:(id)sender {
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
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}

- (IBAction)clickBack:(id)sender {
    [self.firstPhaseContentView setHidden:NO];
    [self.secondPhaseContentView setHidden:YES];
}

@end
