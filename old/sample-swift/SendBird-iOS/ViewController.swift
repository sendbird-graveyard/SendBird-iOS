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
        
        self.userIdLineView.backgroundColor = Constants.textFieldLineColorNormal()
        self.nicknameLineView.backgroundColor = Constants.textFieldLineColorNormal()
        
        self.connectButton.setBackgroundImage(Utils.imageFromColor(color: Constants.connectButtonColor()), for: UIControl.State.normal)
        
        self.indicatorView.hidesWhenStopped = true
        
        self.userIdTextField.addTarget(self, action: #selector(userIdTextFieldDidChange(sender:)), for: UIControl.Event.editingChanged)
        self.nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(sender:)), for: UIControl.Event.editingChanged)
        
        
    }

    @IBAction func clickConnectButton(_ sender: AnyObject) {
        self.connect()
    }
    
    func connect() {
        let trimmedUserId: String = (self.userIdTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces))!
        let trimmedNickname: String = (self.nicknameTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces))!
        
        guard trimmedUserId.count > 0 && trimmedNickname.count > 0 else {
            return
        }
        
        self.userIdTextField.isEnabled = false
        self.nicknameTextField.isEnabled = false
        
        self.indicatorView.startAnimating()
        
        ConnectionManager.login(userId: trimmedUserId, nickname: trimmedNickname) { (user, error) in
            DispatchQueue.main.async {
                self.userIdTextField.isEnabled = true
                self.nicknameTextField.isEnabled = true
                
                self.indicatorView.stopAnimating()
            }
            
            guard error == nil else {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertController.Style.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertAction.Style.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                let vc: MenuViewController = MenuViewController()
                self.present(vc, animated: false, completion: nil)
            }
        }
    }

    @objc func userIdTextFieldDidChange(sender: UITextField) {
        if sender.text?.count == 0 {
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
    
    @objc func nicknameTextFieldDidChange(sender: UITextField) {
        if sender.text?.count == 0 {
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
