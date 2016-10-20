//
//  CreateGroupChannelSelectOptionViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "CreateGroupChannelSelectOptionViewController.h"
#import "NSBundle+SendBird.h"
#import "Constants.h"

@interface CreateGroupChannelSelectOptionViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *distinctButton;
@property (weak, nonatomic) IBOutlet UIButton *nonDistinctButton;
@property (atomic) BOOL isDistinct;
@property (weak, nonatomic) IBOutlet UIButton *distinctTextButton;
@property (weak, nonatomic) IBOutlet UIButton *nonDistinctTextButton;

@end

@implementation CreateGroupChannelSelectOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;
    
    UIBarButtonItem *leftBackItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    UIBarButtonItem *righCreateItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle sbLocalizedStringForKey:@"CreateButton"] style:UIBarButtonItemStylePlain target:self action:@selector(createChannel)];
    [righCreateItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftBackItem];
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, righCreateItem];
    
    self.activityIndicator.hidden = YES;
    [self.activityIndicator hidesWhenStopped];
    [self.activityIndicator stopAnimating];
    
    [self.distinctTextButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.nonDistinctTextButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self selectDictinctOption];
    
    self.isDistinct = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)createChannel {
    [SBDGroupChannel createChannelWithUsers:self.selectedUser isDistinct:self.isDistinct completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
        if (error != nil) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [vc addAction:closeAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
            
            [self.activityIndicator stopAnimating];
            
            return;
        }
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"GroupChannelCreatedTitle"] message:[NSBundle sbLocalizedStringForKey:@"GroupChannelCreatedMessage"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (self.delegate != nil) {
                    [self.delegate didFinishCreatingGroupChannel:channel viewController:self];
                }
            }];
        }];
        [vc addAction:closeAction];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
        [self.activityIndicator stopAnimating];
    }];
}

- (void)selectDictinctOption {
    self.isDistinct = YES;
    
    [self.distinctButton setBackgroundImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.distinctButton setBackgroundImage:[UIImage imageNamed:@"btn_check_off"] forState:UIControlStateHighlighted];
    [self.nonDistinctButton setBackgroundImage:[UIImage imageNamed:@"btn_check_off"] forState:UIControlStateNormal];
    [self.nonDistinctButton setBackgroundImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateHighlighted];
    
    self.distinctTextButton.titleLabel.font = [Constants distinctButtonSelected];
    self.nonDistinctTextButton.titleLabel.font = [Constants distinctButtonNormal];
}

- (void)selectNonDistinctOption {
    self.isDistinct = NO;
    
    [self.distinctButton setBackgroundImage:[UIImage imageNamed:@"btn_check_off"] forState:UIControlStateNormal];
    [self.distinctButton setBackgroundImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateHighlighted];
    [self.nonDistinctButton setBackgroundImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateNormal];
    [self.nonDistinctButton setBackgroundImage:[UIImage imageNamed:@"btn_check_off"] forState:UIControlStateHighlighted];
    
    self.distinctTextButton.titleLabel.font = [Constants distinctButtonNormal];
    self.nonDistinctTextButton.titleLabel.font = [Constants distinctButtonSelected];
}

- (IBAction)clickDistinctButton:(id)sender {
    [self selectDictinctOption];
}

- (IBAction)clickDistinctTextButton:(id)sender {
    [self selectDictinctOption];
}

- (IBAction)clickNondistinctButton:(id)sender {
    [self selectNonDistinctOption];
}

- (IBAction)clickNonDistinctTextButton:(id)sender {
    [self selectNonDistinctOption];
}

@end
