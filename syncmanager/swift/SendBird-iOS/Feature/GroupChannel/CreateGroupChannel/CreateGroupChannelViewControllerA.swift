//
//  CreateGroupChannelViewControllerA.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class CreateGroupChannelViewControllerA: BaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, NotificationDelegate {
    var selectedUsers: [SBDUser] = []
    
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
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
        self.title = "Choose Member"
        
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
        
        self.tableView.register(SelectableUserTableViewCell.nib(), forCellReuseIdentifier: "SelectableUserTableViewCell")

        self.setupScrollView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(CreateGroupChannelViewControllerA.refreshUserList), for: .valueChanged)
        
        self.tableView.refreshControl = self.refreshControl
        
        self.userListQuery = nil
        
        
        self.okButtonItem?.isEnabled = !self.selectedUsers.isEmpty
        self.okButtonItem?.title = "OK(\(Int(self.selectedUsers.count))"
        
        self.refreshUserList()
    }
    
    func setupScrollView() {
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
    }
    
    @objc func clickCancelCreateGroupChannel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func clickOkButton(_ sender: AnyObject) {
        let vc = CreateGroupChannelViewControllerB.initiate()
        vc.members = self.selectedUsers
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelURL: String) {
        self.dismiss(animated: false) {
            let delegate = UIViewController.currentViewController() as? NotificationDelegate
            delegate?.openChat(channelURL)
        }
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

    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath)) as! SelectedUserCollectionViewCell
        
        cell.profileImageView.setProfileImageView(for: selectedUsers[indexPath.row])
        cell.nicknameLabel.text = selectedUsers[indexPath.row].nickname
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedUsers.remove(at: indexPath.row)
        self.okButtonItem?.title = "OK(\(Int(self.selectedUsers.count)))"
        
        if self.selectedUsers.count == 0 {
            self.okButtonItem?.isEnabled = false
        }
        else {
            self.okButtonItem?.isEnabled = true
        }
        
        DispatchQueue.main.async {
            if self.selectedUsers.count == 0 {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableUserTableViewCell") as! SelectableUserTableViewCell
        cell.user = self.users[indexPath.row]
        
        DispatchQueue.main.async {
            if let updateCell = tableView.cellForRow(at: indexPath) as? SelectableUserTableViewCell {
                updateCell.nicknameLabel.text = self.users[indexPath.row].nickname
                updateCell.profileImageView.setProfileImageView(for: self.users[indexPath.row])
                
                if let user = self.users[exists: indexPath.row] {
                    updateCell.selectedUser = self.selectedUsers.contains(user)
                }
                
            }
        }
        
        if self.users.count > 0 && indexPath.row == self.users.count - 1 {
            self.loadUserListNextPage(false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let user = self.users[exists: indexPath.row] {
            if self.selectedUsers.contains(user) {
                self.selectedUsers.removeObject(user)
            } else {
                self.selectedUsers.append(user)
            }
        }
        
        self.okButtonItem?.title = "OK(\(Int(self.selectedUsers.count)))"
        
        if self.selectedUsers.count == 0 {
            self.okButtonItem?.isEnabled = false
        }
        else {
            self.okButtonItem?.isEnabled = true
        }
        
        DispatchQueue.main.async {
            if self.selectedUsers.count > 0 {
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
                    for user in users ?? [] {
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

extension CreateGroupChannelViewControllerA {
    static func initiate() -> CreateGroupChannelViewControllerA {
        
        let vc = CreateGroupChannelViewControllerA.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
