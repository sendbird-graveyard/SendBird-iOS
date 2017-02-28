//
//  ViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class ViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var userIdLineView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var nicknameLineView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var userIdLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var nicknameLabelBottomMargin: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Version
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        if path != nil {
            let infoDict = NSDictionary(contentsOfFile: path!)
            let sampleUIVersion = infoDict?["CFBundleShortVersionString"] as! String
            let version = String(format: "Sample UI v%@ / SDK v%@", sampleUIVersion, SBDMain.getSDKVersion())
            self.versionLabel.text = version
        }
        
        self.userIdTextField.delegate = self
        self.nicknameTextField.delegate = self
        
        self.userIdLabel.alpha = 0
        self.nicknameLabel.alpha = 0
        
        let userId = UserDefaults.standard.object(forKey: "sendbird_user_id") as? String
        let userNickname = UserDefaults.standard.object(forKey: "sendbird_user_nickname") as? String
        
        self.userIdLineView.backgroundColor = Constants.textFieldLineColorNormal()
        self.nicknameLineView.backgroundColor = Constants.textFieldLineColorNormal()
        
        if userId != nil && (userId?.characters.count)! > 0 {
            self.userIdLabelBottomMargin.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.userIdLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        if userNickname != nil && (userNickname?.characters.count)! > 0 {
            self.nicknameLabelBottomMargin.constant = 0
            self.view.setNeedsUpdateConstraints()
            self.nicknameLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        self.userIdTextField.text = userId
        self.nicknameTextField.text = userNickname
        
        self.connectButton.setBackgroundImage(Utils.imageFromColor(color: Constants.connectButtonColor()), for: UIControlState.normal)
        
        self.indicatorView.hidesWhenStopped = true
        
        self.userIdTextField.addTarget(self, action: #selector(userIdTextFieldDidChange(sender:)), for: UIControlEvents.editingChanged)
        self.nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(sender:)), for: UIControlEvents.editingChanged)
    }

    @IBAction func clickConnectButton(_ sender: AnyObject) {
        let trimmedUserId: String = (self.userIdTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces))!
        let trimmedNickname: String = (self.nicknameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces))!
        if trimmedUserId.characters.count > 0 && trimmedNickname.characters.count > 0 {
            self.userIdTextField.isEnabled = false
            self.nicknameTextField.isEnabled = false
            
            self.indicatorView.startAnimating()
            SBDMain.connect(withUserId: trimmedUserId, completionHandler: { (user, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.userIdTextField.isEnabled = true
                        self.nicknameTextField.isEnabled = true
                        
                        self.indicatorView.stopAnimating()
                    }
                    
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                if SBDMain.getPendingPushToken() != nil {
                    SBDMain.registerDevicePushToken(SBDMain.getPendingPushToken()!, unique: true, completionHandler: { (status, error) in
                        if error == nil {
                            if status == SBDPushTokenRegistrationStatus.pending {
                                print("Push registeration is pending.")
                            }
                            else {
                                print("APNS Token is registered.")
                            }
                        }
                        else {
                            print("APNS registration failed.")
                        }
                    })
                }
                
                SBDMain.updateCurrentUserInfo(withNickname: trimmedNickname, profileUrl: nil, completionHandler: { (error) in
                    DispatchQueue.main.async {
                        self.userIdTextField.isEnabled = true
                        self.nicknameTextField.isEnabled = true
                        
                        self.indicatorView.stopAnimating()
                    }
                    
                    if error != nil {
                        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                        
                        SBDMain.disconnect(completionHandler: { 
                            
                        })
                        
                        return
                    }
                    
                    UserDefaults.standard.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
                    UserDefaults.standard.set(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_user_nickname")
                })
                
                DispatchQueue.main.async {
                    let vc = MenuViewController(nibName: "MenuViewController", bundle: Bundle.main)
                    self.present(vc, animated: false, completion: nil)
                }
            })
        }
    }

    func userIdTextFieldDidChange(sender: UITextField) {
        if sender.text?.characters.count == 0 {
            self.userIdLabelBottomMargin.constant = -12
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.1, animations: { 
                self.userIdLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
        else {
            self.userIdLabelBottomMargin.constant = 0
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, animations: {
                self.userIdLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func nicknameTextFieldDidChange(sender: UITextField) {
        if sender.text?.characters.count == 0 {
            self.nicknameLabelBottomMargin.constant = -12
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.1, animations: {
                self.nicknameLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
        else {
            self.nicknameLabelBottomMargin.constant = 0
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, animations: {
                self.nicknameLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }

    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.userIdTextField {
            self.userIdLineView.backgroundColor = Constants.textFieldLineColorSelected()
        }
        else if textField == self.nicknameTextField {
            self.nicknameLineView.backgroundColor = Constants.textFieldLineColorSelected()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.userIdTextField {
            self.userIdLineView.backgroundColor = Constants.textFieldLineColorNormal()
        }
        else if textField == self.nicknameTextField {
            self.nicknameLineView.backgroundColor = Constants.textFieldLineColorNormal()
        }
    }
}
