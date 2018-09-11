//
//  MenuViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MenuViewController: UIViewController, ConnectionManagerDelegate, SBDConnectionDelegate {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var openChannelView: UIView!
    @IBOutlet weak var groupChannelView: UIView!
    
    @IBOutlet weak var openChannelCheckImageView: UIImageView!
    @IBOutlet weak var groupChannelCheckImageView: UIImageView!

    var groupChannelListViewController: GroupChannelListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = true

        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        let rightDisconnectItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "DisconnectButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(disconnect))
        rightDisconnectItem.setTitleTextAttributes([NSAttributedStringKey.font: Constants.navigationBarButtonItemFont()], for: UIControlState.normal)
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let leftProfileItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "Profile"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(profile))
        leftProfileItem.setTitleTextAttributes([NSAttributedStringKey.font: Constants.navigationBarButtonItemFont()], for: UIControlState.normal)
        
        self.navItem.rightBarButtonItems = [negativeRightSpacer, rightDisconnectItem]
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftProfileItem]
        
        ConnectionManager.add(connectionObserver: self as ConnectionManagerDelegate)
        
        if let channelUrl = AppDelegate.sharedInstance().receivedPushChannelUrl  {
            SBDGroupChannel.getWithUrl(channelUrl, completionHandler: { channel, error in
                let vc = GroupChannelChattingViewController()
                vc.groupChannel = channel
                DispatchQueue.main.async {
                    self.present(vc, animated: false, completion: nil)
                }
            })
        }
        
        if SBDMain.getConnectState() == .closed {
            ConnectionManager.login { (user, error) in
                guard error == nil else {
                    return
                }
            }
        }
    }
    
    deinit {
        ConnectionManager.remove(connectionObserver: self as ConnectionManagerDelegate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressOpenChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.groupChannelView.backgroundColor = UIColor.white
        
        self.openChannelCheckImageView.isHidden = false
        self.groupChannelCheckImageView.isHidden = true
    }

    @IBAction func clickOpenChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.groupChannelView.backgroundColor = UIColor.white
        
        self.openChannelCheckImageView.isHidden = false
        self.groupChannelCheckImageView.isHidden = true
        
        let vc = OpenChannelListViewController(nibName: "OpenChannelListViewController", bundle: Bundle.main)
        self.present(vc, animated: false) {
            vc.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    @IBAction func pressGroupChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor.white
        self.groupChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = false
    }
    
    private func showGroupChannelList() {
        self.openChannelView.backgroundColor = UIColor.white
        self.groupChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = false
        
        if self.groupChannelListViewController == nil {
            self.groupChannelListViewController = GroupChannelListViewController(nibName: "GroupChannelListViewController", bundle: Bundle.main)
            self.groupChannelListViewController?.addDelegates()
        }
        
        self.present(self.groupChannelListViewController!, animated: false) {
            self.groupChannelListViewController?.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    @IBAction func clickGroupChannelButton(_ sender: AnyObject) {
        self.showGroupChannelList()
    }

    @objc func disconnect() {
        SBDMain.unregisterAllPushToken { (response, error) in
            if error != nil {
                print("Unregister all push tokens. Error: %@", error!)
            }
            
            SBDMain.disconnect(completionHandler: {
                self.presentLoginViewController()
            })
        }
    }
    
    @objc private func profile() {
        let vc = UserProfileViewController()
        DispatchQueue.main.async {
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    private func presentLoginViewController() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
            if UIApplication.shared.delegate?.window??.rootViewController is MenuViewController {
                let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                let loginViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "com.sendbird.sample.viewcontroller.initial")
                self.present(loginViewController, animated: false, completion: nil)
            }
            else {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: GroupChannelChattingViewController
    func didConnect(isReconnection: Bool) {
        if let channelUrl = AppDelegate.sharedInstance().receivedPushChannelUrl  {
            // reset url to nil
            AppDelegate.sharedInstance().receivedPushChannelUrl = nil
            
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while ((topViewController?.presentedViewController) != nil) {
                topViewController = topViewController?.presentedViewController
            }
            
            if topViewController is GroupChannelChattingViewController {
                if (topViewController as! GroupChannelChattingViewController).groupChannel.channelUrl == channelUrl {
                    return
                }
            }
            
            SBDGroupChannel.getWithUrl(channelUrl, completionHandler: { channel, error in
                let vc = GroupChannelChattingViewController()
                vc.groupChannel = channel
                DispatchQueue.main.async {
                    topViewController?.present(vc, animated: false, completion: nil)
                }
            })
        }
    }
    
    func didDisconnect() {
        //
    }
}
