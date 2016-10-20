//
//  CreateOpenChannelViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/20/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>

#import "CreateOpenChannelViewController.h"
#import "NSBundle+SendBird.h"
#import "Constants.h"

@interface CreateOpenChannelViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *openChannelNameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *channelNameLabelBottomMargin;

@end

@implementation CreateOpenChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *legativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    legativeLeftSpacer.width = -2;
    UIBarButtonItem *legativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    legativeRightSpacer.width = -2;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close"] style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle sbLocalizedStringForKey:@"CreateButton"] style:UIBarButtonItemStylePlain target:self action:@selector(createOpenChannel)];
    [rightItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];

    self.navItem.leftBarButtonItems = @[legativeLeftSpacer, leftItem];
    self.navItem.rightBarButtonItems = @[legativeRightSpacer, rightItem];
    
    self.channelNameLabel.alpha = 0;
    self.openChannelNameTextField.delegate = self;
    self.lineView.backgroundColor = [Constants textFieldLineColorNormal];
    
    [self.openChannelNameTextField addTarget:self action:@selector(channelNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)createOpenChannel {
    if (self.openChannelNameTextField.text.length == 0) {
        return;
    }
    
    [SBDOpenChannel createChannelWithName:self.openChannelNameTextField.text coverUrl:nil data:nil operatorUsers:nil completionHandler:^(SBDOpenChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            return;
        }
        
        [self.delegate refreshView:self];
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"OpenChannelCreatedTitle"] message:[NSBundle sbLocalizedStringForKey:@"OpenChannelCreatedMessage"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        [vc addAction:closeAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    }];
}

- (void)channelNameTextFieldDidChange:(UITextField *)sender {
    if (sender.text.length == 0) {
        self.channelNameLabelBottomMargin.constant = -12;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.1 animations:^{
            self.channelNameLabel.alpha = 0;
            [self.view layoutIfNeeded];
        }];
    }
    else {
        self.channelNameLabelBottomMargin.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            self.channelNameLabel.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.openChannelNameTextField) {
        self.lineView.backgroundColor = [Constants textFieldLineColorSelected];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.openChannelNameTextField) {
        self.lineView.backgroundColor = [Constants textFieldLineColorNormal];
    }
}


@end
