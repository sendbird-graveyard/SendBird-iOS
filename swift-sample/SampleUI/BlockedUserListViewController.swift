//
//  BlockedUserListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class BlockedUserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var blockedUsers: [SBDUser] = []
    fileprivate var query: SBDUserListQuery?
    fileprivate var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Blocked Users"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.query = SBDMain.createBlockedUserListQuery()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(BlockedUserListViewController.refreshBlockedUsers), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.loadBlockedUsers()
    }

    func refreshBlockedUsers() {
        if self.query != nil && self.query?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.blockedUsers.removeAll()
        self.query = SBDMain.createBlockedUserListQuery()
        self.loadBlockedUsers()
    }
    
    fileprivate func loadBlockedUsers() {
        if self.query?.isLoading() == true {
            return
        }
        
        if self.query?.hasNext == false {
            return
        }
        
        self.query?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if users == nil || users!.count == 0 {
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            for user: SBDUser in users! {
                self.blockedUsers.append(user)
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.blockedUsers[(indexPath as NSIndexPath).row]
        let userIndex = (indexPath as NSIndexPath).row
        
        if user.userId == SBDMain.getCurrentUser()!.userId {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
        let unblockUserAction = UIAlertAction(title: "Unblock user", style: UIAlertActionStyle.destructive) { (action) in
            SBDMain.unblockUser(user, completionHandler: { (error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
                else {
                    let alert = UIAlertController(title: "User Unblocked", message: String(format: "%@ is unblocked", user.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                    self.blockedUsers.remove(at: userIndex)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            })
        }
        
        alert.addAction(closeAction)
        alert.addAction(unblockUserAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.blockedUsers[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(false)
        
        if self.blockedUsers.count > 0 {
            if (indexPath as NSIndexPath).row == self.blockedUsers.count - 1 {
                self.loadBlockedUsers()
            }
        }
        
        return cell
    }
}
