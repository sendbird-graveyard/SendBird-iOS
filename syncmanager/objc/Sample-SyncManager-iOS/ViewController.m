//
//  ViewController.m
//  SendBird-iOS-LocalCache-Sample
//
//  Created by Jed Kyung on 9/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>

#import "ViewController.h"
#import "Constants.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ConnectionManager.h"
#import "GroupChannelListViewController.h"
#import <Photos/Photos.h>

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
    
    self.userIdLineView.backgroundColor = [Constants textFieldLineColorNormal];
    self.nicknameLineView.backgroundColor = [Constants textFieldLineColorNormal];
    
    [self.connectButton setBackgroundImage:[Utils imageFromColor:[Constants connectButtonColor]] forState:UIControlStateNormal];
    
    [self.indicatorView setHidesWhenStopped:YES];

    [self.userIdTextField addTarget:self action:@selector(userIdTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.nicknameTextField addTarget:self action:@selector(nicknameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

//- (void)applicationEnteredForeground:(id)sender {
//    NSString *userId = self.userIdTextField.text;
//    NSString *nickname = self.nicknameTextField.text;
//    
//    if (userId != nil && userId.length > 0 && nickname != nil && nickname.length > 0) {
//        [self connect];
//    }
//}

- (IBAction)clickConnectButton:(id)sender {
    [self connect];
}

- (void)connect {
    NSString *trimmedUserId = [self.userIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedNickname = [self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedUserId.length > 0 && trimmedNickname.length > 0) {
        [self.userIdTextField setEnabled:NO];
        [self.nicknameTextField setEnabled:NO];
        
        [self.indicatorView startAnimating];

        [ConnectionManager loginWithUserId:trimmedUserId nickname:trimmedNickname completionHandler:^(SBDUser * _Nullable user, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.userIdTextField setEnabled:YES];
                [self.nicknameTextField setEnabled:YES];
                
                [self.indicatorView stopAnimating];
            });
            
            if (error != nil) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *vc = [[GroupChannelListViewController alloc] init];
                [self presentViewController:vc animated:NO completion:nil];                
            });
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
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
