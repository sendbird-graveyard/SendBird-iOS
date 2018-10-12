//
//  AppDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AVKit
import AVFoundation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var receivedPushChannelUrl: String?
    
    static let instance: NSCache<AnyObject, AnyObject> = NSCache()

    static func imageCache() -> NSCache<AnyObject, AnyObject>! {
        if AppDelegate.instance.totalCostLimit == 104857600 {
            AppDelegate.instance.totalCostLimit = 104857600
        }
        
        return AppDelegate.instance
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.registerForRemoteNotification()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: Constants.navigationBarTitleFont()]
        UINavigationBar.appearance().tintColor = Constants.navigationBarTitleColor()
        
        application.applicationIconBadgeNumber = 0
        
        SBDMain.initWithApplicationId("9DA1B1F4-0BE6-4DA8-82C5-2E81DAB56F23")
        SBDMain.setLogLevel(SBDLogLevel.none)
        SBDOptions.setUseMemberAsMessageSender(true)
        
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback, options: [])
            } else {
                // Fallback on earlier versions
            }
        }
        catch {
            
        }
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let storyboard: UIStoryboard = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        let launchViewController: UIViewController? = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = launchViewController
        self.window?.makeKeyAndVisible()
        
        ConnectionManager.login { (user, error) in
            guard error == nil else {
                let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController: UIViewController? = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = viewController
                self.window?.makeKeyAndVisible()
                return;
            }
            
            self.window?.rootViewController = MenuViewController()
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            #if !(arch(i386) || arch(x86_64))
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) -> Void  in
                        guard settings.authorizationStatus == UNAuthorizationStatus.authorized else {
                            return;
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    })
                }
            }
            #endif
        } else {
            #if !(arch(i386) || arch(x86_64))
            let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            #endif
        }
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    
                }
                else {
                    
                }
            }
            else {
                
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if userInfo["sendbird"] != nil {
            let sendBirdPayload = userInfo["sendbird"] as! Dictionary<String, Any>
            let channel = (sendBirdPayload["channel"]  as! Dictionary<String, Any>)["channel_url"] as! String
            let channelType = sendBirdPayload["channel_type"] as! String
            if channelType == "group_messaging" {
                self.receivedPushChannelUrl = channel
            }
        }
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("method for handling events for background url session is waiting to be process. background session id: \(identifier)")
        completionHandler()
    }
}

