//
//  SettingsViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos 
import MobileCoreServices

class SettingsViewController: UITableViewController, SettingsTableViewCellDelegate, UserProfileImageNameSettingDelegate, NotificationDelegate {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    
    
    var showPreview: Bool = false
    var createDistinctChannel: Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Settings"
        self.navigationItem.largeTitleDisplayMode = .automatic

        let nickname = SBDMain.getCurrentUser()?.nickname ?? ""
        
        self.nicknameLabel.text = nickname
        if nickname.isEmpty {
            let attributes: [NSAttributedString.Key : Any] = [ .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
                                                               .foregroundColor: UIColor.gray ]
            self.nicknameLabel.attributedText = NSAttributedString(string: "Please write your nickname", attributes: attributes)
        }
        
        self.userIdLabel.text = SBDMain.getCurrentUser()?.userId
        DispatchQueue.main.async {
            guard let user = SBDMain.getCurrentUser() else { return }
            self.profileImageView.setProfileImageView(for: user)
        }

        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        
        if let showPreview = UserDefaults.standard.object(forKey: Constants.ID_SHOW_PREVIEWS) as? Bool {
            self.showPreview = showPreview
        }
        
        if let createDistinctChannel = UserDefaults.standard.object(forKey: Constants.ID_CREATE_DISTINCT_CHANNEL) as? Bool {
            self.createDistinctChannel = createDistinctChannel
        }
    }

    // MARK: - NotificationDelegate
    func openChat(_ channelURL: String) {
        let tabBarVC = self.navigationController?.parent as? UITabBarController
        tabBarVC?.selectedIndex = 0
        
        let delegate = UIViewController.currentViewController() as? NotificationDelegate
        delegate?.openChat(channelURL)
        
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            let userProfileVC = UpdateUserProfileViewController.inintiate()
            userProfileVC.delegate = self
            self.show(userProfileVC, sender: nil)
            
        case 1:
            let settingTimeVC = SettingsTimeViewController.initiate()
            self.show(settingTimeVC, sender: nil)
            
        case 2:
            break
            
        case 3:
            
            let blockedUserListVC = SettingsBlockedUserListViewController.initiate()
            self.show(blockedUserListVC, sender: nil)
            
        case 4:
            
            AlertControl.show(parent: self,
                              title: "Sign Out",
                              message: "Do you want to sign out?",
                              actionMessage: "OK")
            { action in
                
                if let pushToken = SBDMain.getPendingPushToken() {
                    SBDMain.unregisterPushToken(pushToken) { response, error in
                        /// Fixed Optional Problem(.getPendingPushToken()! -> pushToken)
                    }
                }
                
                ConnectionControl.logout {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - SettingsTableViewCellDelegate
    func didChangeSwitchButton(isOn: Bool, identifier: String) {
        
        switch identifier {
            
        case Constants.ID_SHOW_PREVIEWS:
            
            UserDefaults.standard.set(isOn, forKey: Constants.ID_SHOW_PREVIEWS)
            UserDefaults.standard.synchronize()
            self.showPreview = isOn
            
        case Constants.ID_CREATE_DISTINCT_CHANNEL:
            
            UserDefaults.standard.set(isOn, forKey: Constants.ID_CREATE_DISTINCT_CHANNEL)
            UserDefaults.standard.synchronize()
            self.createDistinctChannel = isOn
            
        default:
            break
        }
    }
    
    // MARK: - UserProfileImageNameSettingDelegate
    func didUpdateUserProfile() {
        
        let nickname = SBDMain.getCurrentUser()?.nickname ?? ""
        
        self.nicknameLabel.text = nickname
        if nickname.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
                .foregroundColor: UIColor.gray as Any
            ]
            self.nicknameLabel.attributedText = NSAttributedString(string: "Please write your nickname", attributes: attributes)
        }
        self.userIdLabel.text = SBDMain.getCurrentUser()?.userId
        DispatchQueue.main.async {
            guard let user = SBDMain.getCurrentUser() else { return }
            self.profileImageView.setProfileImageView(for: user)
        }
    }
}
