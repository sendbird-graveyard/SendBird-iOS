//
//  AppDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/3/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import UserNotifications
import SendBirdSDK
import AVKit
import AVFoundation
import Alamofire
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDAuthenticateDelegate {

    var window: UIWindow?
    var receivedPushChannelUrl: String?
    var pushReceivedGroupChannel: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SBDOptions.setConnectionTimeout(5)
        SBDOptions.setAuthenticationTimeout(10)
        
        SBDMain.initWithApplicationId("9DA1B1F4-0BE6-4DA8-82C5-2E81DAB56F23")
        
        self.registerForRemoteNotification()
        
        DataRequest.addAcceptableImageContentTypes(["binary/octet-stream"])
        
        UINavigationBar.appearance().tintColor = UIColor(named: "color_navigation_tint")
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = self.window {
            let launchScreenStoryboard = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
            let launchViewController = launchScreenStoryboard.instantiateViewController(withIdentifier: "LaunchScreenViewController")
            window.rootViewController = launchViewController
            window.makeKeyAndVisible()
            
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func registerForRemoteNotification() {
        if self.compareVersions(version1: UIDevice.current.systemVersion, version2: "10.0") >= 0 {
#if !targetEnvironment(simulator)
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                if granted == true {
                    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                        if settings.authorizationStatus != UNAuthorizationStatus.authorized {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    })
                }
            }
            
            return
#else
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert]) { (granted, error) in
                
            }
#endif
        }
        else {
#if !targetEnvironment(simulator)
            if UIApplication.shared.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
                let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
#endif
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    print("Push registration is pending.")
                }
                else {
                    print("APNS Token is registered.")
                }
            }
            else {
                print("APNS registration failed with error: \(String(describing: error))")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get token, error: \(String(describing: error))")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let sendbirdDict = userInfo["sendbird"] as? [String:Any] {
            if let channelDict  = sendbirdDict["channel"] as? [String:Any] {
                self.pushReceivedGroupChannel = channelDict["channel_url"] as? String
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.request.content.userInfo as? [String : Any] else { return }
        guard let sendbirdDict = userInfo["sendbird"] as? [String:Any] else { return }
        guard let channelDict = sendbirdDict["channel"] as? [String:Any] else { return }
        guard let channelUrl = channelDict["channel_url"] as? String else { return }
        self.pushReceivedGroupChannel = channelUrl
        
        SBDConnectionManager.setAuthenticateDelegate(self)
        SBDConnectionManager.authenticate()
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func jumpToGroupChannel(_ channelUrl: String?) -> Void {
        let vc = UIViewController.currentViewController()
        
        if vc is GroupChannelsViewController {
            (vc as! GroupChannelsViewController).openChat(channelUrl!)
        }
        else if vc is GroupChannelChatViewController {
            (vc as! GroupChannelChatViewController).openChat(channelUrl!)
        }
        else if vc is GroupChannelSettingsViewController {
            (vc as! GroupChannelSettingsViewController).openChat(channelUrl!)
        }
        else if vc is GroupChannelCoverImageNameSettingViewController {
            (vc as! GroupChannelCoverImageNameSettingViewController).openChat(channelUrl!)
        }
        else if vc is GroupChannelInviteMemberViewController {
            (vc as! GroupChannelInviteMemberViewController).openChat(channelUrl!)
        }
        else if vc is CreateGroupChannelViewControllerA {
            (vc as! CreateGroupChannelViewControllerA).openChat(channelUrl!)
        }
        else if vc is CreateGroupChannelViewControllerB {
            (vc as! CreateGroupChannelViewControllerB).openChat(channelUrl!)
        }
        else if vc is UserProfileViewController {
            (vc as! UserProfileViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelsViewController {
            (vc as! OpenChannelsViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelChatViewController {
            (vc as! OpenChannelChatViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelSettingsViewController {
            (vc as! OpenChannelSettingsViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelParticipantListViewController {
            (vc as! OpenChannelParticipantListViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelBannedUserListViewController {
            (vc as! OpenChannelBannedUserListViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelMutedUserListViewController {
            (vc as! OpenChannelMutedUserListViewController).openChat(channelUrl!)
        }
        else if vc is SelectOperatorsViewController {
            (vc as! SelectOperatorsViewController).openChat(channelUrl!)
        }
        else if vc is OpenChannelCoverImageNameSettingViewController {
            (vc as! OpenChannelCoverImageNameSettingViewController).openChat(channelUrl!)
        }
        else if vc is CreateOpenChannelViewControllerA {
            (vc as! CreateOpenChannelViewControllerA).openChat(channelUrl!)
        }
        else if vc is CreateOpenChannelViewControllerB {
            (vc as! CreateOpenChannelViewControllerB).openChat(channelUrl!)
        }
        else if vc is SettingsViewController {
            (vc as! SettingsViewController).openChat(channelUrl!)
        }
        else if vc is UpdateUserProfileViewController {
            (vc as! UpdateUserProfileViewController).openChat(channelUrl!)
        }
        else if vc is SettingsBlockedUserListViewController {
            (vc as! SettingsBlockedUserListViewController).openChat(channelUrl!)
        }
        else if vc is LoginViewController {
            (vc as! LoginViewController).openChat(channelUrl!)
        }
    }

    // MARK: SBDAuthenticateDelegate
    func shouldHandleAuthInfo(completionHandler: @escaping (String?, String?, String?, String?) -> Void) {
        let userId = UserDefaults.standard.value(forKey: "sendbird_user_id") as? String
        completionHandler(userId, nil, nil, nil)
    }
    
    func didFinishAuthentication(with user: SBDUser?, error: SBDError?) {
        if error == nil {
            UserDefaults.standard.setValue(true, forKey: "sendbird_auto_login")
            UserDefaults.standard.synchronize()
            
            SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, unique: true) { (status, error) in
                if error != nil {
                    print("APNS registration failed with error: \(String(describing: error))")
                    return
                }
                
                if status == SBDPushTokenRegistrationStatus.pending {
                    print("Push registration is pending.")
                }
                else {
                    print("APNS Token is registered.")
                }
            }
            
            if self.pushReceivedGroupChannel != nil {
                guard let vc = UIViewController.currentViewController() else {
                    self.pushReceivedGroupChannel = nil
                    return
                }
                
                if vc is UIAlertController {
                    vc.dismiss(animated: false) {
                        self.jumpToGroupChannel(self.pushReceivedGroupChannel)
                    }
                }
                else {
                    self.jumpToGroupChannel(self.pushReceivedGroupChannel)
                }
                
                self.pushReceivedGroupChannel = nil
            }
            else {
                if let currentViewController = UIViewController.currentViewController() {
                    let mainTabBarController = MainTabBarController.init(nibName: "MainTabBarController", bundle: nil)
                    currentViewController.present(mainTabBarController, animated: false, completion: nil)
                }
            }
        }
    }
    
    // Swift version only.
    private func compareVersions(version1: String, version2: String) -> Int {
        var ret: Int = 0
        
        var v1:[Int] = version1.split(separator: ".").map { (substring) -> Int in
            return Int(substring)!
        }
        var v2 = version2.split(separator: ".").map { (substring) -> Int in
            return Int(substring)!
        }
        
        let cntv1 = v1.count
        let cntv2 = v2.count
        let mincnt = cntv1 < cntv2 ? cntv1 : cntv2
        
        for i in 0..<mincnt {
            if v1[i] == v2[i] {
                ret = 0
                continue
            }
            else if v1[i] > v2[i] {
                ret = 1
            }
            else {
                ret = -1
            }
            
            break
        }
        
        if ret == 0 {
            if cntv1 > cntv2 {
                ret = 1
            }
            else if cntv1 < cntv2 {
                ret = -1
            }
        }
        
        return ret
    }
}

