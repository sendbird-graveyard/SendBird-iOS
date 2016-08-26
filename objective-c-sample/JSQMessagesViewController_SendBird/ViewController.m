//
//  ViewController.m
//  JSQMessagesViewController_SendBird
//
//  Created by Jed Gyeong on 4/23/16.
//  Copyright © 2016 SENDBIRD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *openChannelButton;
@property (weak, nonatomic) IBOutlet UIButton *groupChannelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (atomic) BOOL connected;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_name"];
    
    [self.userIdTextField setText:userId];
    [self.nicknameTextField setText:userName];
    
    self.connected = NO;
    
    [self.activityIndicatorView setHidden:YES];
    [self.openChannelButton setEnabled:NO];
    [self.groupChannelButton setEnabled:NO];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    if (path != nil) {
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *sampleUIVersion = infoDict[@"CFBundleShortVersionString"];
        NSString *version = [NSString stringWithFormat:@"SDK v%@\nSample UI for Objective-C v%@", [SBDMain getSDKVersion], sampleUIVersion];
        self.versionLabel.text = version;
    }
}

- (IBAction)clickConnectButton:(id)sender {
    if (self.userIdTextField.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"User ID is required." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:closeAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }
    
    if (self.nicknameTextField.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Nickname is required." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:closeAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }
    
    if (self.connected) {
        [SBDMain disconnectWithCompletionHandler:^{
            self.connected = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.openChannelButton.enabled = NO;
                self.groupChannelButton.enabled = NO;
                self.userIdTextField.enabled = YES;
                [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            });
        }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
        });
        [self.userIdTextField setEnabled:NO];
        [SBDMain connectWithUserId:[self.userIdTextField text] completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
            if (error == nil) {
                [SBDMain updateCurrentUserInfoWithNickname:[self.nicknameTextField text] profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
                    if (error != nil) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%ld: %@", error.code, error.domain] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:closeAction];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController:alert animated:YES completion:nil];
                            [self.activityIndicatorView setHidden:YES];
                            [self.activityIndicatorView stopAnimating];
                        });
                        
                        return;
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].userId forKey:@"sendbird_user_id"];
                    [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].nickname forKey:@"sendbird_user_name"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.connected = YES;
                        [self.openChannelButton setEnabled:YES];
                        [self.groupChannelButton setEnabled:YES];
                        [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
                        
                        [self.activityIndicatorView stopAnimating];
                        [self.activityIndicatorView setHidden:YES];
                    });
                }];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%ld: %@", error.code, error.domain] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    [self.userIdTextField setEnabled:YES];
                    
                    [self.activityIndicatorView setHidden:YES];
                    [self.activityIndicatorView stopAnimating];
                });
            }
        }];
    }
}

- (IBAction)clickOpenChannelButon:(id)sender {
    OpenChannelListViewController *vc = [[OpenChannelListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickGroupChannelButton:(id)sender {
    GroupChannelListViewController *vc = [[GroupChannelListViewController alloc] init];
    [vc setUserID:[SBDMain getCurrentUser].userId userName:[SBDMain getCurrentUser].nickname];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
