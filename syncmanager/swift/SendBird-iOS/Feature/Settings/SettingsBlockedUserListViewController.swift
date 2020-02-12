//
//  SettingsBlockedUserListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK 

class SettingsBlockedUserListViewController: BaseViewController, NotificationDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var users: [SBDUser] = []
    var userListQuery: SBDUserListQuery?
    var refreshControl: UIRefreshControl?
    var tabBarHidden: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Blocked Users"
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(SettingsBlockedUserListViewController.refreshUserList), for: .valueChanged)
        
        self.tableView.refreshControl = self.refreshControl
        
        self.userListQuery = nil
        
        self.refreshUserList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    // MARK: - NotificationDelegate
    func openChat(_ channelURL: String) {
        self.navigationController?.popViewController(animated: false)
        guard let currentVC = UIViewController.currentViewController(), let delegate = currentVC as? NotificationDelegate else { return }
        delegate.openChat(channelURL)

    }

    // MARK: - Load users
    @objc func refreshUserList() {
        self.loadUserListNextPage(true)
    }
    
    func loadUserListNextPage(_ refresh: Bool) {
        if refresh {
            self.userListQuery = nil
        }
        
        if self.userListQuery == nil {
            self.userListQuery = SBDMain.createBlockedUserListQuery()
            self.userListQuery?.limit = 20
        }
        
        if (self.userListQuery?.hasNext ?? false) == false {
            return
        }
        
        self.userListQuery?.loadNextPage() { users, error in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.users.removeAll()
                }
                
                self.users += users ?? []
                self.tableView.reloadData()
                
                self.refreshControl?.endRefreshing()
            }
        }
    }
}

extension SettingsBlockedUserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let tableCell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserTableViewCell") as? BlockedUserTableViewCell {
            tableCell.user = self.users[indexPath.row]
            
            DispatchQueue.main.async {
                if let updateCell = tableView.cellForRow(at: indexPath) as? BlockedUserTableViewCell {
                    updateCell.nicknameLabel.text = self.users[indexPath.row].nickname
                    updateCell.profileImageView.setProfileImageView(for: self.users[indexPath.row])
                }
            }
            
            cell = tableCell
        }
        
        if self.users.count > 0 && indexPath.row == self.users.count - 1 {
            self.loadUserListNextPage(false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.emptyLabel.isHidden = !self.users.isEmpty
        return self.users.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        
        let actionSeeProfile = UIAlertAction(title: "See profile", style: .default) { (action) in
            let userProfileVC = UserProfileViewController.initiate()
            userProfileVC.user = user
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(userProfileVC, animated: true)
            }
        }
        
        let actionUnblock = UIAlertAction(title: "Unblock", style: .default) { (action) in
            SBDMain.unblockUser(user, completionHandler: { (error) in
                if error != nil {
                    return
                }
                
                DispatchQueue.main.async {
                    self.users.remove(at: self.users.firstIndex(of: user)!)
                    self.tableView.reloadData()
                }
            })
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        AlertControl.show(parent: self,
                          actions: [actionSeeProfile, actionUnblock, actionCancel],
                          title: user.nickname,
                          style: .actionSheet)
    }
}
extension SettingsBlockedUserListViewController {
    static func initiate() -> SettingsBlockedUserListViewController {
        let vc = SettingsBlockedUserListViewController.withStoryboard(storyboard: .settings)
        return vc
    }
}
