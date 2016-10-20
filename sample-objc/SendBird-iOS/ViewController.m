//
//  ViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>

#import "ViewController.h"
#import "MenuViewController.h"
#import "Constants.h"
#import "NSBundle+SendBird.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIView *userIdLineView;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIView *nicknameLineView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userIdLabelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nicknameLabelBottomMargin;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Version
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    if (path != nil) {
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *sampleUIVersion = infoDict[@"CFBundleShortVersionString"];
        NSString *version = [NSString stringWithFormat:@"Sample UI v%@ / SDK v%@", sampleUIVersion, [SBDMain getSDKVersion]];
        self.versionLabel.text = version;
    }

    self.userIdTextField.delegate = self;
    self.nicknameTextField.delegate = self;
    
    self.userIdLabel.alpha = 0;
    self.nicknameLabel.alpha = 0;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_id"];
    NSString *userNickname = [[NSUserDefaults standardUserDefaults] objectForKey:@"sendbird_user_nickname"];

    self.userIdLineView.backgroundColor = [Constants textFieldLineColorNormal];
    self.nicknameLineView.backgroundColor = [Constants textFieldLineColorNormal];
    
    if (userId != nil && userId.length > 0) {
        self.userIdLabelBottomMargin.constant = 0;
        [self.view setNeedsUpdateConstraints];
        self.userIdLabel.alpha = 1;
        [self.view layoutIfNeeded];
    }
    
    if (userNickname != nil && userNickname.length > 0) {
        self.nicknameLabelBottomMargin.constant = 0;
        [self.view setNeedsUpdateConstraints];
        self.nicknameLabel.alpha = 1;
        [self.view layoutIfNeeded];
    }
    
    self.userIdTextField.text = userId;
    self.nicknameTextField.text = userNickname;
    
    [self.indicatorView setHidesWhenStopped:YES];

    [self.userIdTextField addTarget:self action:@selector(userIdTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.nicknameTextField addTarget:self action:@selector(nicknameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (IBAction)clickConnectButton:(id)sender {
    NSString *trimmedUserId = [self.userIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedNickname = [self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedUserId.length > 0 && trimmedNickname.length > 0) {
        [self.userIdTextField setEnabled:NO];
        [self.nicknameTextField setEnabled:NO];
        
        [self.indicatorView startAnimating];
        [SBDMain connectWithUserId:trimmedUserId completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.userIdTextField setEnabled:YES];
                    [self.nicknameTextField setEnabled:YES];
                    
                    [self.indicatorView stopAnimating];
                });
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                
                return;
            }
            
            [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                if (error == nil) {
                    if (status == SBDPushTokenRegistrationStatusPending) {
                        NSLog(@"Push registration is pending.");
                    }
                    else {
                        NSLog(@"APNS Token is registered.");
                    }
                }
                else {
                    NSLog(@"APNS registration failed.");
                }
            }];
            
            [SBDMain updateCurrentUserInfoWithNickname:trimmedNickname profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.userIdTextField setEnabled:YES];
                    [self.nicknameTextField setEnabled:YES];
                    
                    [self.indicatorView stopAnimating];
                });
                
                if (error != nil) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                    
                    [SBDMain disconnectWithCompletionHandler:^{
                        
                    }];
                    
                    return;
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].userId forKey:@"sendbird_user_id"];
                [[NSUserDefaults standardUserDefaults] setObject:[SBDMain getCurrentUser].nickname forKey:@"sendbird_user_nickname"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    MenuViewController *vc = [[MenuViewController alloc] init];
                    [self presentViewController:vc animated:NO completion:nil];
                });
            }];
        }];
    }
}

- (void)userIdTextFieldDidChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        self.userIdLabelBottomMargin.constant = -12;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.1 animations:^{
            self.userIdLabel.alpha = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        self.userIdLabelBottomMargin.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            self.userIdLabel.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)nicknameTextFieldDidChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        self.nicknameLabelBottomMargin.constant = -12;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.1 animations:^{
            self.nicknameLabel.alpha = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        self.nicknameLabelBottomMargin.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            self.nicknameLabel.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.userIdTextField) {
        self.userIdLineView.backgroundColor = [Constants textFieldLineColorSelected];
    }
    else if (textField == self.nicknameTextField) {
        self.nicknameLineView.backgroundColor = [Constants textFieldLineColorSelected];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userIdTextField) {
        self.userIdLineView.backgroundColor = [Constants textFieldLineColorNormal];
    }
    else if (textField == self.nicknameTextField) {
        self.nicknameLineView.backgroundColor = [Constants textFieldLineColorNormal];
    }
}

@end
