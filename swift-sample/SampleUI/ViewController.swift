//
//  ViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class ViewController: UIViewController {
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var openChannelButton: UIButton!
    @IBOutlet weak var groupChannelButton: UIButton!
    
    var delegateIdentifier: NSString!
    var connected: Bool
    
    required init?(coder aDecoder: NSCoder) {
        self.connected = false
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.connected = false
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegateIdentifier = self.description;
        
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("sendbird_user_id") as? String
        let nickname = NSUserDefaults.standardUserDefaults().objectForKey("sendbird_nickname") as? String
        
        self.userIdTextField.text = userId
        self.nicknameTextField.text = nickname
        
        self.connected = false
        
        self.openChannelButton.enabled = false
        self.groupChannelButton.enabled = false
        
        print(self.dynamicType);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickConnectButton(sender: AnyObject) {
        if self.userIdTextField.text?.characters.count == 0 {
            return;
        }
        
        if self.nicknameTextField.text?.characters.count == 0 {
            return;
        }
        
        if self.connected {
            SBDMain.disconnectWithCompletionHandler({
                self.connected = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.openChannelButton.enabled = false
                    self.groupChannelButton.enabled = false
                    self.connectButton.setTitle("Connect", forState: UIControlState.Normal)
                })
            })
        }
        else {
            self.userIdTextField.enabled = false
            SBDMain.connectWithUserId(self.userIdTextField.text!, completionHandler: { (user, error) in
                if error == nil {
                    SBDMain.updateCurrentUserInfoWithNickname(self.nicknameTextField.text, profileUrl: nil, completionHandler: { (error) in
                        if error != nil {
                            print("User info updating error: %@", error)
                        }
                        
                        NSUserDefaults.standardUserDefaults().setObject(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
                        NSUserDefaults.standardUserDefaults().setObject(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_nickname")
                        
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.connected = true
                            self.openChannelButton.enabled = true
                            self.groupChannelButton.enabled = true
                            self.connectButton.setTitle("Disconnect", forState: UIControlState.Normal)
                        })
                    })
                }
                else {
                    print("Connection error: %@", error)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.userIdTextField.enabled = true
                    })
                }
            })
        }
    }
    
    
    @IBAction func clickOpenChannelButon(sender: AnyObject) {
        let vc = OpenChannelListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func clickGroupChannelButton(sender: AnyObject) {
    }
}

