//
//  MenuViewController.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MenuViewController: UIViewController, SBDConnectionDelegate {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var groupChannelView: UIView!
    
    @IBOutlet weak var groupChannelCheckImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.groupChannelCheckImageView.isHidden = true

        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        let rightDisconnectItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "DisconnectButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(disconnect))
        rightDisconnectItem.setTitleTextAttributes([NSAttributedString.Key.font: Constants.navigationBarButtonItemFont()], for: UIControl.State.normal)
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let leftProfileItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "Profile"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(profile))
        leftProfileItem.setTitleTextAttributes([NSAttributedString.Key.font: Constants.navigationBarButtonItemFont()], for: UIControl.State.normal)
        
        self.navItem.rightBarButtonItems = [negativeRightSpacer, rightDisconnectItem]
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftProfileItem]
        
        if (UIApplication.shared.delegate as! AppDelegate).receivedPushChannelUrl != nil {
            let channelUrl = (UIApplication.shared.delegate as! AppDelegate).receivedPushChannelUrl
            if channelUrl != nil {
                SBDGroupChannel.getWithUrl(channelUrl!, completionHandler: { (theChannel, theError) in
                    guard let channel: SBDGroupChannel = theChannel, theError != nil else {
                        return
                    }
                    
                    let vc: GroupChannelChattingViewController = GroupChannelChattingViewController.init(channel: channel)
                    DispatchQueue.main.async {
                        self.present(vc, animated: false, completion: nil)
                    }
                })
            }
        }
        
        if SBDMain.getConnectState() == .closed {
            ConnectionManager.login { (user, error) in
                guard error == nil else {
                    return
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressGroupChannelButton(_ sender: AnyObject) {
        self.groupChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.groupChannelCheckImageView.isHidden = false
    }
    
    private func showGroupChannelList() {
        self.groupChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.groupChannelCheckImageView.isHidden = false
        
        let viewController: GroupChannelListViewController = GroupChannelListViewController()
        self.present(viewController, animated: false) {
            viewController.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
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
            
            ConnectionManager.logout(completionHandler: {
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
}
