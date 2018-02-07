//
//  MenuViewController.m
//  SendBird-iOS
//
//  Created by Jed Kyung on 9/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

#import "MenuViewController.h"
#import "OpenChannelListViewController.h"
#import "GroupChannelListViewController.h"
#import "NSBundle+SendBird.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "GroupChannelChattingViewController.h"
#import "UserProfileViewController.h"
#import "ConnectionManager.h"

@interface MenuViewController () <ConnectionManagerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIView *openChannelView;
@property (weak, nonatomic) IBOutlet UIView *groupChannelView;

@property (weak, nonatomic) IBOutlet UIImageView *openChannelCheckImageView;
@property (weak, nonatomic) IBOutlet UIImageView *groupChannelCheckImageView;

@property (strong, nonatomic) GroupChannelListViewController *groupChannelListViewController;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = YES;
    
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;
    UIBarButtonItem *rightDisconnectItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle sbLocalizedStringForKey:@"DisconnectButton"] style:UIBarButtonItemStylePlain target:self action:@selector(disconnect)];
    [rightDisconnectItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *leftProfileItem = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(profile)];
    [leftProfileItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];

    
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, rightDisconnectItem];
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftProfileItem];
    
    [ConnectionManager addConnectionObserver:self];

    if (((AppDelegate *)[UIApplication sharedApplication].delegate).receivedPushChannelUrl != nil) {
        NSString *channelUrl = ((AppDelegate *)[UIApplication sharedApplication].delegate).receivedPushChannelUrl;
        ((AppDelegate *)[UIApplication sharedApplication].delegate).receivedPushChannelUrl = nil;
        if (channelUrl != nil) {
            [SBDGroupChannel getChannelWithUrl:channelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
                vc.channel = channel;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:NO completion:nil];
                });
            }];
        }
    }
    
    if ([SBDMain getConnectState] == SBDWebSocketClosed) {
        [ConnectionManager connectWithCompletionHandler:^(SBDUser * _Nullable user, NSError * _Nullable error) {
            if (error != nil && error.code == -1) {
                [self presentLoginViewController];
            }
        }];
    }
}

-(void)dealloc {
    [ConnectionManager removeConnectionObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressOpenChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    self.groupChannelView.backgroundColor = [UIColor whiteColor];
    
    self.openChannelCheckImageView.hidden = NO;
    self.groupChannelCheckImageView.hidden = YES;
}

- (IBAction)clickOpenChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    self.groupChannelView.backgroundColor = [UIColor whiteColor];
    
    self.openChannelCheckImageView.hidden = NO;
    self.groupChannelCheckImageView.hidden = YES;
    
    OpenChannelListViewController *vc = [[OpenChannelListViewController alloc] init];
    [self presentViewController:vc animated:NO completion:^{
        vc.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (IBAction)pressGroupChannelButton:(id)sender {
    self.openChannelView.backgroundColor = [UIColor whiteColor];
    self.groupChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = NO;
}

- (void)showGroupChannelList {
    self.openChannelView.backgroundColor = [UIColor whiteColor];
    self.groupChannelView.backgroundColor = [UIColor colorWithRed:(CGFloat)(248.0/255.0) green:(CGFloat)(248.0/255.0) blue:(CGFloat)(248.0/255.0) alpha:1];
    
    self.openChannelCheckImageView.hidden = YES;
    self.groupChannelCheckImageView.hidden = NO;

    self.groupChannelListViewController = [[GroupChannelListViewController alloc] init];
    [self.groupChannelListViewController addDelegates];
    
    [self presentViewController:self.groupChannelListViewController animated:NO completion:^{
        self.groupChannelListViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (IBAction)clickGroupChannelButton:(id)sender {
    [self showGroupChannelList];
}

- (void)disconnect {
    [SBDMain unregisterAllPushTokenWithCompletionHandler:^(NSDictionary * _Nullable response, SBDError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unregister all push tokens. Error: %@", error);
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sendbird_user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sendbird_user_nickname"];
        
        [SBDMain disconnectWithCompletionHandler:^{
            [self presentLoginViewController];
        }];
    }];
}

- (void)profile {
    UserProfileViewController *vc = [[UserProfileViewController alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:NO completion:nil];
    });
}

- (void)presentLoginViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        if ([[UIApplication sharedApplication].delegate.window.rootViewController isKindOfClass:[self class]]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"com.sendbird.sample.viewcontroller.initial"];
            [self presentViewController:loginViewController animated:NO completion:nil];
        }
        else {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    });
}

#pragma mark - Connection Manage Delegate
- (void)didConnect {
    // from push notification
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).receivedPushChannelUrl != nil) {
        NSString *channelUrl = ((AppDelegate *)[UIApplication sharedApplication].delegate).receivedPushChannelUrl;
        ((AppDelegate *)[UIApplication sharedApplication].delegate).receivedPushChannelUrl = nil;
        
        UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        }
        
        if ([topViewController isKindOfClass:[GroupChannelChattingViewController class]]) {
            if ([((GroupChannelChattingViewController *)topViewController).channel.channelUrl isEqualToString:channelUrl]) {
                return;
            }
        }
        
        [SBDGroupChannel getChannelWithUrl:channelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            GroupChannelChattingViewController *vc = [[GroupChannelChattingViewController alloc] init];
            vc.channel = channel;
            dispatch_async(dispatch_get_main_queue(), ^{
                [topViewController presentViewController:vc animated:NO completion:nil];
            });
        }];
    }
}

@end
