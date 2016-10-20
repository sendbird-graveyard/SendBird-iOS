//
//  MenuViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MenuViewController: UIViewController {
    @IBOutlet weak var openChannelView: UIView!
    @IBOutlet weak var groupChannelView: UIView!
    @IBOutlet weak var disconnectView: UIView!
    
    @IBOutlet weak var openChannelCheckImageView: UIImageView!
    @IBOutlet weak var groupChannelCheckImageView: UIImageView!
    @IBOutlet weak var disconnectCheckImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = true
        self.disconnectCheckImageView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressOpenChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.groupChannelView.backgroundColor = UIColor.white
        self.disconnectView.backgroundColor = UIColor.white
        
        self.openChannelCheckImageView.isHidden = false
        self.groupChannelCheckImageView.isHidden = true
        self.disconnectCheckImageView.isHidden = true
    }

    @IBAction func clickOpenChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.groupChannelView.backgroundColor = UIColor.white
        self.disconnectView.backgroundColor = UIColor.white
        
        self.openChannelCheckImageView.isHidden = false
        self.groupChannelCheckImageView.isHidden = true
        self.disconnectCheckImageView.isHidden = true
        
        let vc = OpenChannelListViewController()
        self.present(vc, animated: false) {
            vc.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    @IBAction func pressGroupChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor.white
        self.groupChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.disconnectView.backgroundColor = UIColor.white
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = false
        self.disconnectCheckImageView.isHidden = true
    }
    
    @IBAction func clickGroupChannelButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor.white
        self.groupChannelView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        self.disconnectView.backgroundColor = UIColor.white
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = false
        self.disconnectCheckImageView.isHidden = true
        
        let vc = GroupChannelListViewController()
        self.present(vc, animated: false) {
            vc.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    @IBAction func pressDisconnectButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor.white
        self.groupChannelView.backgroundColor = UIColor.white
        self.disconnectView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = true
        self.disconnectCheckImageView.isHidden = false
    }
    
    @IBAction func clickDisconnectButton(_ sender: AnyObject) {
        self.openChannelView.backgroundColor = UIColor.white
        self.groupChannelView.backgroundColor = UIColor.white
        self.disconnectView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        
        self.openChannelCheckImageView.isHidden = true
        self.groupChannelCheckImageView.isHidden = true
        self.disconnectCheckImageView.isHidden = false
        
        SBDMain.unregisterAllPushToken { (response, error) in
            if error != nil {
                print("Unregister all push tokens. Error: ", error)
            }
            
            SBDMain.disconnect(completionHandler: { 
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    self.dismiss(animated: false, completion: nil)
                }
            })
        }
    }
}
