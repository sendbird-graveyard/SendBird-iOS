//
//  GroupChannelInviteMemberViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelInviteMemberViewController: BaseViewController, NotificationDelegate {
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updatingIndicatorView: CustomActivityIndicatorView!

    weak var delegate: GroupChannelInviteMemberDelegate?
    
    var selectedUsers: [String:SBDUser] = [:]
    var channel: SBDGroupChannel?
    var users: [SBDUser] = []
    var userListQuery: SBDApplicationUserListQuery?
    var refreshControl: UIRefreshControl?
    var searchController: UISearchController?
    var okButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Invite Members"
      
        self.okButtonItem = UIBarButtonItem.init(title: "OK(0)", style: .plain, target: self, action: #selector(GroupChannelInviteMemberViewController.clickOkButton(_:)))
        self.navigationItem.rightBarButtonItem = self.okButtonItem
        
        self.view.bringSubviewToFront(self.updatingIndicatorView)
        self.updatingIndicatorView.isHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(SelectableUserTableViewCell.nib(), forCellReuseIdentifier: "SelectableUserTableViewCell")
        
        self.selectedUserListView.contentInset = UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
        self.selectedUserListView.delegate = self
        self.selectedUserListView.dataSource = self
        self.selectedUserListView.register(SelectedUserCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier())
        self.selectedUserListHeight.constant = 0
        self.selectedUserListView.isHidden = true
        
        self.selectedUserListView.showsHorizontalScrollIndicator = false
        self.selectedUserListView.showsVerticalScrollIndicator = false
        
        if let layout = self.selectedUserListView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshUserList), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.placeholder = "User ID"
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = UIColor(named: "color_bar_item")
        
        self.userListQuery = nil
        
        self.okButtonItem?.isEnabled = !self.selectedUsers.isEmpty
        self.okButtonItem?.title = "OK\(Int(self.selectedUsers.count))"
        
        self.refreshUserList()
    }

    // MARK: - NotificationDelegate
    func openChat(_ channelURL: String) {
        
        navigationController?.popViewController(animated: false)
        
        let delegate = UIViewController.currentViewController() as? NotificationDelegate
        delegate?.openChat(channelURL)
    }
    
    @objc func refreshUserList() {
        self.loadUserListNextPage(refresh: false)
    }
    
    func loadUserListNextPage(refresh: Bool) {
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
                guard let currentUserID = SBDMain.getCurrentUser()?.userId else { return }
                self.users += users?.filter { $0.userId != currentUserID } ?? []
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    @objc func clickOkButton(_ sender: Any) {
        guard let channel = self.channel else { return }
        
        self.updatingIndicatorView.superViewSize = self.view.frame.size
        self.updatingIndicatorView.updateFrame()
        self.updatingIndicatorView.isHidden = false
        self.updatingIndicatorView.startAnimating()
        
        channel.invite(Array(self.selectedUsers.values) as [SBDUser]) { (error) in
            self.updatingIndicatorView.isHidden = true
            self.updatingIndicatorView.stopAnimating()
            
            if let error = error {
                AlertControl.showError(parent: self, error: error)
                return
            }
            
            self.delegate?.didInviteMembers()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension GroupChannelInviteMemberViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath)) as! SelectedUserCollectionViewCell
        
        let selectedUserKeys = self.selectedUsers.keys
        let key = Array(selectedUserKeys)[indexPath.row]
        
        cell.setModel(aUser: selectedUsers[key]!)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUserKeys = self.selectedUsers.keys
        let key = Array(selectedUserKeys)[indexPath.row]
        
        self.selectedUsers.removeValue(forKey: key)
        
        DispatchQueue.main.async {
            if self.selectedUsers.isEmpty {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
}

extension GroupChannelInviteMemberViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableUserTableViewCell", for: indexPath) as! SelectableUserTableViewCell
        
        cell.user = self.users[indexPath.row]
        self.okButtonItem?.title = "OK (\(Int(self.selectedUsers.count)))"
        self.okButtonItem?.isEnabled = !self.selectedUsers.isEmpty
        
        DispatchQueue.main.async {
            if let updateCell = tableView.cellForRow(at: indexPath) as? SelectableUserTableViewCell {
                let user = self.users[indexPath.row]
                updateCell.nicknameLabel.text = user.nickname
                updateCell.profileImageView.setProfileImageView(for: user)
                updateCell.selectedUser = self.selectedUsers[user.userId] != nil
            }
        }
        
        if self.users.count > 0 && indexPath.row == self.users.count - 1 {
            self.loadUserListNextPage(refresh: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
}

extension GroupChannelInviteMemberViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        if self.selectedUsers[user.userId] != nil {
            self.selectedUsers.removeValue(forKey: user.userId)
        }
        else {
            self.selectedUsers[user.userId] = user
        }
        
        self.okButtonItem?.title = "OK(\(Int(self.selectedUsers.count)))"
        self.okButtonItem?.isEnabled = !self.selectedUsers.isEmpty
        
        DispatchQueue.main.async {
            if self.selectedUsers.keys.count > 0 {
                self.selectedUserListHeight.constant = 70
                self.selectedUserListView.isHidden = false
            }
            else {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            
            self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.selectedUserListView.reloadData()
        }
    }
}
// MARK: - UISearchBarDelegate
extension GroupChannelInviteMemberViewController: UISearchBarDelegate {
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
                    for user in users ?? [] {
                        if user.userId == SBDMain.getCurrentUser()?.userId {
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

extension GroupChannelInviteMemberViewController {
    static func initiate() -> GroupChannelInviteMemberViewController {
        let vc = GroupChannelInviteMemberViewController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
