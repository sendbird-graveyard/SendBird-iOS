//
//  CreateGroupChannelViewControllerA.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class CreateGroupChannelViewControllerA: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NotificationDelegate {
    var selectedUsers: [String : SBDUser] = [:]
    
    @IBOutlet weak var tableView: UITableView!
    var users: [SBDUser] = []
    var userListQuery: SBDApplicationUserListQuery?
    var refreshControl: UIRefreshControl?
    var searchController: UISearchController?
    
    var okButtonItem: UIBarButtonItem?
    var cancelButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Create Group Channel"
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.okButtonItem = UIBarButtonItem(title: "OK(0)", style: .plain, target: self, action: #selector(CreateGroupChannelViewControllerA.clickOkButton(_:)))
        self.navigationItem.rightBarButtonItem = self.okButtonItem
        
        self.cancelButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CreateGroupChannelViewControllerA.clickCancelCreateGroupChannel(_:)))
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.placeholder = "User ID"
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = UIColor(named: "color_bar_item")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "SelectGroupChannelMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectGroupChannelMemberTableViewCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(CreateGroupChannelViewControllerA.refreshUserList), for: .valueChanged)
        
        self.tableView.refreshControl = self.refreshControl
        
        self.userListQuery = nil
        
        if self.selectedUsers.count == 0 {
            self.okButtonItem?.isEnabled = false
        }
        else {
            self.okButtonItem?.isEnabled = true
        }
        
        self.okButtonItem?.title = String(format: "OK(%d)", Int(self.selectedUsers.count))
        
        self.refreshUserList()
    }
    
    @objc func clickCancelCreateGroupChannel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func clickOkButton(_ sender: AnyObject) {
        let vc = CreateGroupChannelViewControllerB.init(nibName: "CreateGroupChannelViewControllerB", bundle: nil)
        vc.members = Array(self.selectedUsers.values)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        self.dismiss(animated: false) {
            let cvc = UIViewController.currentViewController()
            if cvc is GroupChannelsViewController {
                (cvc as! GroupChannelsViewController).openChat(channelUrl)
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
    
    // MARK: - Load users
    @objc func refreshUserList() {
        self.loadUserListNextPage(true)
    }
    
    func loadUserListNextPage(_ refresh: Bool) {
        if refresh {
            self.userListQuery = nil
        }
        
        if self.userListQuery == nil {
            self.userListQuery = SBDMain.createApplicationUserListQuery()
            self.userListQuery?.limit = 20
        }
        
        if self.userListQuery?.hasNext == false {
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.users.removeAll()
                }
                
                for user in users! {
                    if user.userId == SBDMain.getCurrentUser()!.userId {
                        continue
                    }
                    self.users.append(user)
                }
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        })
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGroupChannelMemberTableViewCell") as! SelectGroupChannelMemberTableViewCell
        cell.user = self.users[indexPath.row]
        
        DispatchQueue.main.async {
            if let updateCell = tableView.cellForRow(at: indexPath) as? SelectGroupChannelMemberTableViewCell {
                updateCell.nicknameLabel.text = self.users[indexPath.row].nickname
                Utils.setProfileImage(imageView: updateCell.profileImageView, user: self.users[indexPath.row])
                
                if self.selectedUsers[self.users[indexPath.row].userId] != nil {
                    updateCell.selectedUser = true
                }
                else {
                    updateCell.selectedUser = false
                }
            }
        }
        
        if self.users.count > 0 && indexPath.row == self.users.count - 1 {
            self.loadUserListNextPage(false)
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedUsers[self.users[indexPath.row].userId] != nil {
            self.selectedUsers.removeValue(forKey: self.users[indexPath.row].userId)
        }
        else {
            self.selectedUsers[self.users[indexPath.row].userId] = self.users[indexPath.row]
        }
        
        self.okButtonItem!.title = String(format: "OK(%d)", Int(self.selectedUsers.count))
        
        if self.selectedUsers.count == 0 {
            self.okButtonItem?.isEnabled = false
        }
        else {
            self.okButtonItem?.isEnabled = true
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.refreshUserList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.userListQuery = SBDMain.createApplicationUserListQuery()
            self.userListQuery?.userIdsFilter = [searchText]
            self.userListQuery?.loadNextPage(completionHandler: { (users, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.users.removeAll()
                    for user in users! {
                        if user.userId == SBDMain.getCurrentUser()!.userId {
                            continue
                        }
                        self.users.append(user)
                    }
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            })
        }
    }
}
