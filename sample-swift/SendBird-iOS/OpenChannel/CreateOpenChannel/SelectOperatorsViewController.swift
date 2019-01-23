//
//  SelectOperatorsViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class SelectOperatorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NotificationDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectOperatorsDelegate?
    var selectedUsers: [String: SBDUser] = [:]
    
    var users: [SBDUser] = []
    var userListQuery: SBDApplicationUserListQuery?
    var refreshControl: UIRefreshControl?
    var searchController: UISearchController?
    var okButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.largeTitleDisplayMode = .automatic
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        if let prevVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] {
            prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        }
        
        self.okButtonItem = UIBarButtonItem(title: "OK(0)", style: .plain, target: self, action: #selector(SelectOperatorsViewController.clickOkButton(_:)))
        self.navigationItem.rightBarButtonItem = self.okButtonItem
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "SelectOperatorsTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectOperatorsTableViewCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(SelectOperatorsViewController.refreshUserList), for: .valueChanged)
        
        self.tableView.refreshControl = self.refreshControl
        
        self.searchController = UISearchController.init(searchResultsController: nil)
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.placeholder = "User ID"
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = UIColor(named: "color_bar_item")
        self.searchController?.searchBar.showsCancelButton = true
        
        if self.selectedUsers.count == 0 {
            self.okButtonItem?.isEnabled = false
        }
        else {
            self.okButtonItem?.isEnabled = true
        }
        
        self.okButtonItem?.title = String(format: "OK(%d)", Int(self.selectedUsers.count))
        
        self.refreshUserList()
    }

    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        }
        
        let cvc = UIViewController.currentViewController()
        if cvc is OpenChannelSettingsViewController {
            (cvc as? OpenChannelSettingsViewController)?.openChat(channelUrl)
        }
        else if cvc is OpenChannelSettingsViewController {
            (cvc as? OpenChannelSettingsViewController)?.openChat(channelUrl)
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
            self.userListQuery!.limit = 20
        }
        
        if self.userListQuery!.hasNext == false {
            return
        }
        
        self.userListQuery!.loadNextPage { (users, error) in
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
        }
    }
    
    @objc func clickOkButton(_ sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.didSelectUsers(self.selectedUsers)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectOperatorsTableViewCell") as! SelectOperatorsTableViewCell
        cell.user = self.users[indexPath.row]
        
        DispatchQueue.main.async {
            if let updateCell = tableView.cellForRow(at: indexPath) as? SelectOperatorsTableViewCell {
                updateCell.nicknameLabel.text = self.users[indexPath.row].nickname
                if let url = URL(string: Utils.transformUserProfileImage(user: self.users[indexPath.row])) {
                    updateCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.users[indexPath.row]))
                }
                else {
                    updateCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.users[indexPath.row])
                }
                
                if self.selectedUsers[self.users[indexPath.row].userId] != nil {
                   updateCell.selectedOperator = true
                }
                else {
                    updateCell.selectedOperator = false
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
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.refreshUserList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.userListQuery = SBDMain.createApplicationUserListQuery()
            self.userListQuery?.userIdsFilter = [searchText]
            self.userListQuery!.loadNextPage { (users, error) in
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
            }
        }
    }
}
