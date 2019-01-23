//
//  OpenChannelBannedUserListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelBannedUserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationDelegate {
    var channel: SBDOpenChannel?
    
    private var bannedListQuery: SBDUserListQuery?
    private var bannedUsers: [SBDUser] = []
    private var refreshControl: UIRefreshControl?

    @IBOutlet weak var bannedUsersTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Banned Users"
        self.navigationItem.largeTitleDisplayMode = .automatic
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        guard let navigationController = self.navigationController else { return }
        let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(OpenChannelBannedUserListViewController.refreshBannedUserList), for: .valueChanged)
        
        self.bannedUsersTableView.register(UINib(nibName: "OpenChannelSettingsUserTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsUserTableViewCell")
        self.bannedUsersTableView.refreshControl = self.refreshControl
        
        self.bannedUsersTableView.delegate = self
        self.bannedUsersTableView.dataSource = self
        
        self.loadBannedUserListNextPage(refresh: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func refreshBannedUserList() {
        self.loadBannedUserListNextPage(refresh: true)
    }
    
    func loadBannedUserListNextPage(refresh: Bool) {
        if refresh {
            self.bannedListQuery = nil
        }
        
        guard let channel = self.channel else { return }
        if self.bannedListQuery == nil {
            self.bannedListQuery = channel.createBannedUserListQuery()
            self.bannedListQuery?.limit = 20
        }
        
        if self.bannedListQuery?.hasNext == false {
            return
        }
        
        self.bannedListQuery?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.bannedUsers.removeAll()
                }
                
                self.bannedUsers += users!
                self.bannedUsersTableView.reloadData()
                
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: false)
        if let cvc = UIViewController.currentViewController() {
            if cvc is OpenChannelSettingsViewController {
                (cvc as! OpenChannelSettingsViewController).openChat(channelUrl)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let userCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsUserTableViewCell") as? OpenChannelSettingsUserTableViewCell {
            let bannedUser = self.bannedUsers[indexPath.row]
            userCell.nicknameLabel.text = bannedUser.nickname
            userCell.user = bannedUser
            
            cell = userCell
            
            DispatchQueue.main.async {
                if let updateCell = tableView.cellForRow(at: indexPath) as? OpenChannelSettingsUserTableViewCell {
                    if let url = URL(string: Utils.transformUserProfileImage(user: self.bannedUsers[indexPath.row])) {
                        updateCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.bannedUsers[indexPath.row]))
                    }
                    else {
                        updateCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.bannedUsers[indexPath.row])
                    }
                }
            }
        }
        
        if self.bannedUsers.count > 0 && indexPath.row == self.bannedUsers.count - 1 {
            self.loadBannedUserListNextPage(refresh: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.bannedUsers.count == 0 {
            self.emptyLabel.isHidden = false
        }
        else {
            self.emptyLabel.isHidden = true
        }
        
        return self.bannedUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let bannedUser = self.bannedUsers[indexPath.row]
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionSeeProfile = UIAlertAction(title: "See profile", style: .default) { (action) in
            let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
            vc.user = bannedUser
            DispatchQueue.main.async {
                guard let navigationController = self.navigationController else { return }
                navigationController.pushViewController(vc, animated: true)
            }
        }
        
        let actionUnbanUser = UIAlertAction(title: "Unban user", style: .default) { (action) in
            guard let channel = self.channel else { return }
            channel.unbanUser(bannedUser, completionHandler: { (error) in
                if error != nil {
                    return
                }
                
                DispatchQueue.main.async {
                    self.bannedUsers.removeObject(bannedUser)
                    self.bannedUsersTableView.reloadData()
                }
            })
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(actionSeeProfile)
        ac.addAction(actionUnbanUser)
        ac.addAction(actionCancel)
        
        DispatchQueue.main.async {
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
