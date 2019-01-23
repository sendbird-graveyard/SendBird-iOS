//
//  UserProfileViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class UserProfileViewController: UIViewController, NotificationDelegate {
    var user: SBDUser?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var onlineStateLabel: UILabel!
    @IBOutlet weak var onlineStateImageView: UIImageView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Profile"
        self.navigationItem.largeTitleDisplayMode = .automatic
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        guard let navigationController = self.navigationController else { return }
        let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        
        self.refreshUserInfo(self.user!)
        
        let query = SBDMain.createApplicationUserListQuery()
        query?.userIdsFilter = [self.user!.userId]
        query?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                Utils.showAlertController(error: error!, viewController: self)
                return
            }
            
            if (users?.count)! > 0 {
                self.refreshUserInfo(users![0])
            }
        })
    }

    func refreshUserInfo(_ user: SBDUser) {
        if let url = URL(string: Utils.transformUserProfileImage(user: user)) {
            self.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: user))
        }
        else {
            self.profileImageView.image = Utils.getDefaultUserProfileImage(user: user)
        }
        
        self.nicknameLabel.text = user.nickname
        
        if user.connectionStatus == .online {
            self.onlineStateImageView.image = UIImage(named: "img_online")
            self.onlineStateLabel.text = "Online"
            self.lastUpdatedLabel.isHidden = true
        }
        else {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        }
        let cvc = UIViewController.currentViewController()
        if cvc is GroupChannelSettingsViewController {
            (cvc as? GroupChannelSettingsViewController)?.openChat(channelUrl)
        }
        else if cvc is GroupChannelChatViewController {
            (cvc as? GroupChannelChatViewController)?.openChat(channelUrl)
        }
        else if cvc is OpenChannelBannedUserListViewController {
            (cvc as? OpenChannelBannedUserListViewController)?.openChat(channelUrl)
        }
        else if cvc is OpenChannelMutedUserListViewController {
            (cvc as? OpenChannelMutedUserListViewController)?.openChat(channelUrl)
        }
        else if cvc is OpenChannelParticipantListViewController {
            (cvc as? OpenChannelParticipantListViewController)?.openChat(channelUrl)
        }
        else if cvc is OpenChannelSettingsViewController {
            (cvc as? OpenChannelSettingsViewController)?.openChat(channelUrl)
        }
        else if cvc is SettingsBlockedUserListViewController {
            (cvc as? SettingsBlockedUserListViewController)?.openChat(channelUrl)
        }
    }
}
