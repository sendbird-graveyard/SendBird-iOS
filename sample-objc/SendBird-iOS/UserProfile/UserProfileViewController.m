//
//  UserProfileViewController.m
//  SendBird-iOS
//
//  Created by Jed Gyeong on 3/27/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

#import <SendBirdSDK/SendBirdSDK.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFImageDownloader.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>

#import "UserProfileViewController.h"
#import "Constants.h"
#import "NSBundle+SendBird.h"


@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updatingIndicator;

@property (strong) NSData *profileImageData;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *negativeRightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeRightSpacer.width = -2;
    UIBarButtonItem *rightDisconnectItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    [rightDisconnectItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    UIBarButtonItem *negativeLeftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeLeftSpacer.width = -2;
    UIBarButtonItem *leftProfileItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    [leftProfileItem setTitleTextAttributes:@{NSFontAttributeName: [Constants navigationBarButtonItemFont]} forState:UIControlStateNormal];
    
    self.navItem.rightBarButtonItems = @[negativeRightSpacer, rightDisconnectItem];
    self.navItem.leftBarButtonItems = @[negativeLeftSpacer, leftProfileItem];
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[SBDMain getCurrentUser].profileUrl]];
    
    self.profileImageData = nil;
    
    self.updatingIndicator.hidden = YES;
    
    UITapGestureRecognizer *profileImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProfileImage)];
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:profileImageTapRecognizer];
    
    [self.nicknameTextField setText:[SBDMain getCurrentUser].nickname];
    
    BOOL isRegisteredForRemoteNotifications = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    [self.pushNotificationSwitch setOn:isRegisteredForRemoteNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)save {
    if ([self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return;
    }
    
    self.updatingIndicator.hidden = NO;
    [self.updatingIndicator startAnimating];
    
    BOOL isRegisteredForRemoteNotifications = [self.pushNotificationSwitch isOn];
    if (isRegisteredForRemoteNotifications) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [SBDMain updateCurrentUserInfoWithNickname:[self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] profileImage:self.profileImageData completionHandler:^(SBDError * _Nullable error) {
            BOOL hasUpdatedUserInfo;
            if (error != nil) {
                hasUpdatedUserInfo = NO;
            }
            else {
                AFImageDownloader *imageDownloader = [AFImageDownloader defaultInstance];
                NSURLCache *urlCache = imageDownloader.sessionManager.session.configuration.URLCache;
                [urlCache removeAllCachedResponses];
                [imageDownloader.imageCache removeImageWithIdentifier:[SBDMain getCurrentUser].profileUrl];
                
                hasUpdatedUserInfo = YES;
            }

#if !(TARGET_OS_SIMULATOR)
            [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                BOOL hasUpdatedPushNoti;
                
                if (error != nil) {
                    hasUpdatedPushNoti = NO;
                }
                else {
                    hasUpdatedPushNoti = YES;
                }
                
                if (hasUpdatedUserInfo == NO || hasUpdatedPushNoti == NO) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:@"Couldn't update the user information" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    
                    self.updatingIndicator.hidden = YES;
                    [self.updatingIndicator stopAnimating];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                }
                else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
#else
            if (hasUpdatedUserInfo == NO) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:@"Couldn't update the user information" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                
                self.updatingIndicator.hidden = YES;
                [self.updatingIndicator stopAnimating];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
#endif
        }];
    }
    else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [SBDMain updateCurrentUserInfoWithNickname:[self.nicknameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] profileImage:self.profileImageData completionHandler:^(SBDError * _Nullable error) {
            BOOL hasUpdatedUserInfo;
            if (error != nil) {
                hasUpdatedUserInfo = NO;
            }
            else {
                AFImageDownloader *imageDownloader = [AFImageDownloader defaultInstance];
                NSURLCache *urlCache = imageDownloader.sessionManager.session.configuration.URLCache;
                [urlCache removeAllCachedResponses];
                [imageDownloader.imageCache removeImageWithIdentifier:[SBDMain getCurrentUser].profileUrl];
                
                hasUpdatedUserInfo = YES;
            }
            
#if !(TARGET_OS_SIMULATOR)
            [SBDMain unregisterPushToken:[SBDMain getPendingPushToken] completionHandler:^(NSDictionary * _Nullable response, SBDError * _Nullable error) {
                BOOL hasUpdatedPushNoti;
                
                if (error != nil) {
                    hasUpdatedPushNoti = NO;
                }
                else {
                    hasUpdatedPushNoti = YES;
                }

                if (hasUpdatedUserInfo == NO || hasUpdatedPushNoti == NO) {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:@"Couldn't update the user information" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                    [vc addAction:closeAction];
                    
                    self.updatingIndicator.hidden = YES;
                    [self.updatingIndicator stopAnimating];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:vc animated:YES completion:nil];
                    });
                }
                else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
#else
            if (hasUpdatedUserInfo == NO) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSBundle sbLocalizedStringForKey:@"ErrorTitle"] message:@"Couldn't update the user information" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[NSBundle sbLocalizedStringForKey:@"CloseButton"] style:UIAlertActionStyleCancel handler:nil];
                [vc addAction:closeAction];
                
                self.updatingIndicator.hidden = YES;
                [self.updatingIndicator stopAnimating];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
#endif
        }];
    }
}

- (void)clickProfileImage {
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSMutableArray *mediaTypes = [[NSMutableArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    mediaUI.mediaTypes = mediaTypes;
    [mediaUI setDelegate:self];
    [self presentViewController:mediaUI animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __weak UserProfileViewController *weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UserProfileViewController *strongSelf = weakSelf;
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
            PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[imagePath] options:nil] lastObject];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = NO;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                NSNumber *isError = [info objectForKey:PHImageErrorKey];
                NSNumber *isCloud = [info objectForKey:PHImageResultIsInCloudKey];
                if ([isError boolValue] || [isCloud boolValue] || !imageData) {
                    // fail
                } else {
                    // success, data is in imageData
                    [strongSelf cropImage:imageData];
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)cropImage:(NSData *)imageData {
    UIImage *image = [UIImage imageWithData:imageData];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image];
    imageCropVC.delegate = self;
    imageCropVC.cropMode = RSKImageCropModeSquare;
    [self presentViewController:imageCropVC animated:NO completion:nil];
}

#pragma mark - RSKImageCropViewControllerDelegate
// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    self.profileImageView.image = croppedImage;
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    self.profileImageView.image = croppedImage;
    self.profileImageData = UIImageJPEGRepresentation(croppedImage, 1);
    [controller dismissViewControllerAnimated:NO completion:nil];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES.
}

@end
