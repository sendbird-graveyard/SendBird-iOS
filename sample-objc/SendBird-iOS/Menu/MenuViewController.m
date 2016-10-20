//
//  MenuViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>

#import "MenuViewController.h"
#import "OpenChannelListViewController.h"
#import "GroupChannelListViewController.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *openChannelView;
@property (weak, nonatomic) IBOutlet UIView *groupChannelView;
@property (weak, nonatomic) IBOutlet UIView *disconnectView;

@property (weak, nonatomic) IBOutlet UIImageView *openChannelCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *groupChannelCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *disconnectCheckImageView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = YES;
    self.disconnectCheckImageView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressOpenChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    self.groupChannelView.backgroundColor = [UIColor whiteColor];
    self.disconnectView.backgroundColor = [UIColor whiteColor];
    
    self.openChannelCheckImageView.hidden = NO;
    self.groupChannelCheckImageView.hidden = YES;
    self.disconnectCheckImageView.hidden = YES;
}

- (IBAction)clickOpenChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    self.groupChannelView.backgroundColor = [UIColor whiteColor];
    self.disconnectView.backgroundColor = [UIColor whiteColor];
    
    self.openChannelCheckImageView.hidden = NO;
    self.groupChannelCheckImageView.hidden = YES;
    self.disconnectCheckImageView.hidden = YES;
    
    OpenChannelListViewController *vc = [[OpenChannelListViewController alloc] init];
    [self presentViewController:vc animated:NO completion:^{
        vc.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (IBAction)pressGroupChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor whiteColor];
    self.groupChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    self.disconnectView.backgroundColor = [UIColor whiteColor];
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = NO;
    self.disconnectCheckImageView.hidden = YES;
}

- (IBAction)clickGroupChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor whiteColor];
    self.groupChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    self.disconnectView.backgroundColor = [UIColor whiteColor];
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = NO;
    self.disconnectCheckImageView.hidden = YES;
    
    GroupChannelListViewController *vc = [[GroupChannelListViewController alloc] init];
    [self presentViewController:vc animated:NO completion:^{
        vc.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (IBAction)pressDisconnectButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor whiteColor];
    self.groupChannelView.backgroundColor = [UIColor whiteColor];
    self.disconnectView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = YES;
    self.disconnectCheckImageView.hidden = NO;
}

- (IBAction)clickDisconnectButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor whiteColor];
    self.groupChannelView.backgroundColor = [UIColor whiteColor];
    self.disconnectView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = YES;
    self.disconnectCheckImageView.hidden = NO;
    
    [SBDMain unregisterAllPushTokenWithCompletionHandler:^(NSDictionary * _Nullable response, SBDError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unregister all push tokens. Error: %@", error);
        }
        
        [SBDMain disconnectWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                [self dismissViewControllerAnimated:NO completion:nil];
            });
        }];
    }];
    
    
}

@end
