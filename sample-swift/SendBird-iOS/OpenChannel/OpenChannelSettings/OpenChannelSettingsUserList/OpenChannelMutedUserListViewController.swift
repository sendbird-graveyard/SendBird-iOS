//
//  OpenChannelMutedUserListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelMutedUserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationDelegate {
    var channel: SBDOpenChannel?
    
    private var mutedListQuery: SBDUserListQuery?
    private var mutedUsers: [SBDUser] = []
    private var refreshControl: UIRefreshControl?

    @IBOutlet weak var mutedUsersTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Muted Users"
        self.navigationItem.largeTitleDisplayMode = .automatic
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        guard let navigationController = self.navigationController else { return }
        let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(OpenChannelMutedUserListViewController.refreshMutedUserList), for: .valueChanged)
        
        self.mutedUsersTableView.register(UINib(nibName: "OpenChannelSettingsUserTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsUserTableViewCell")
        self.mutedUsersTableView.refreshControl = self.refreshControl
        
        self.mutedUsersTableView.delegate = self
        self.mutedUsersTableView.dataSource = self
        
        self.loadMutedUserListNextPage(refresh: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func refreshMutedUserList() {
        self.loadMutedUserListNextPage(refresh: true)
    }
    
    func loadMutedUserListNextPage(refresh: Bool) {
        if refresh {
            self.mutedListQuery = nil
        }
        
        guard let channel = self.channel else { return }
        if self.mutedListQuery == nil {
            self.mutedListQuery = channel.createMutedUserListQuery()
            self.mutedListQuery?.limit = 20
        }
        
        if self.mutedListQuery?.hasNext == false {
            return
        }
        
        self.mutedListQuery?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.mutedUsers.removeAll()
                }
                
                self.mutedUsers += users!
                self.mutedUsersTableView.reloadData()
                
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
            let mutedUser = self.mutedUsers[indexPath.row]
            userCell.nicknameLabel.text = mutedUser.nickname
            userCell.user = mutedUser
            
            cell = userCell
            
            DispatchQueue.main.async {
                if let updateCell = tableView.cellForRow(at: indexPath) as? OpenChannelSettingsUserTableViewCell {
                    if let url = URL(string: Utils.transformUserProfileImage(user: self.mutedUsers[indexPath.row])) {
                        updateCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.mutedUsers[indexPath.row]))
                    }
                    else {
                        updateCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.mutedUsers[indexPath.row])
                    }
                }
            }
        }
        
        if self.mutedUsers.count > 0 && indexPath.row == self.mutedUsers.count - 1 {
            self.loadMutedUserListNextPage(refresh: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mutedUsers.count == 0 {
            self.emptyLabel.isHidden = false
        }
        else {
            self.emptyLabel.isHidden = true
        }
        
        return self.mutedUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let mutedUser = self.mutedUsers[indexPath.row]
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionSeeProfile = UIAlertAction(title: "See profile", style: .default) { (action) in
            let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
            vc.user = mutedUser
            DispatchQueue.main.async {
                guard let navigationController = self.navigationController else { return }
                navigationController.pushViewController(vc, animated: true)
            }
        }
        
        let actionUnmuteUser = UIAlertAction(title: "Unmute user", style: .default) { (action) in
            guard let channel = self.channel else { return }
            channel.unmuteUser(mutedUser, completionHandler: { (error) in
                if error != nil {
                    return
                }
                
                DispatchQueue.main.async {
                    self.mutedUsers.removeObject(mutedUser)
                    self.mutedUsersTableView.reloadData()
                }
            })
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(actionSeeProfile)
        ac.addAction(actionUnmuteUser)
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
