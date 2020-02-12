//
//  UserProfileViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK 

class UserProfileViewController: BaseViewController, NotificationDelegate {
    var user: SBDUser?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var onlineStateLabel: UILabel!
    @IBOutlet weak var onlineStateImageView: UIImageView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        guard let user = self.user else { return }
        self.refreshUserInfo(user)
        
        let query = SBDMain.createApplicationUserListQuery()
        query?.userIdsFilter = [user.userId]
        query?.loadNextPage() { users, error in
            
            if let error = error {
                AlertControl.showError(parent: self, error: error)
                return
            }
            
            if let user = users?.first {
                self.refreshUserInfo(user)
            }
        }
    }

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    func refreshUserInfo(_ user: SBDUser) {
        self.profileImageView.setProfileImageView(for: user)
        self.nicknameLabel.text = user.nickname
        
        switch user.connectionStatus {
        case .online:
            self.onlineStateImageView.image = UIImage(named: "img_online")
            self.onlineStateLabel.text = "Online"
            self.lastUpdatedLabel.isHidden = true
            
        default:
            self.onlineStateImageView.image = UIImage(named: "img_offline")
            self.onlineStateLabel.text = "Offline"
            if user.lastSeenAt > 0 {
                self.lastUpdatedLabel.text = String(format: "Last Updated %@", Utils.getDateStringForDateSeperatorFromTimestamp(user.lastSeenAt))
                self.lastUpdatedLabel.isHidden = false
            }
            else {
                self.lastUpdatedLabel.isHidden = true
            }
        }
 
    }

    // MARK: - NotificationDelegate
    func openChat(_ channelURL: String) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        }
        if let currentVC = UIViewController.currentViewController(), let delegate = currentVC as? NotificationDelegate {
            delegate.openChat(channelURL)
        }
    }
}
extension UserProfileViewController {
    static func initiate() -> UserProfileViewController {
        let vc = UserProfileViewController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
