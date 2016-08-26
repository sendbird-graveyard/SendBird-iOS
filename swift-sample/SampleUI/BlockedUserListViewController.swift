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
    @IBOutlet private weak var tableView: UITableView!
    private var blockedUsers: [SBDUser] = []
    private var query: SBDUserListQuery?
    private var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Blocked Users"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.query = SBDMain.createBlockedUserListQuery()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(BlockedUserListViewController.refreshBlockedUsers), forControlEvents: UIControlEvents.ValueChanged)
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
    
    private func loadBlockedUsers() {
        if self.query?.isLoading() == true {
            return
        }
        
        if self.query?.hasNext == false {
            return
        }
        
        self.query?.loadNextPageWithCompletionHandler({ (users, error) in
            if error != nil {
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if users == nil || users!.count == 0 {
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            for user: SBDUser in users! {
                self.blockedUsers.append(user)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = self.blockedUsers[indexPath.row]
        let userIndex = indexPath.row
        
        if user.userId == SBDMain.getCurrentUser()!.userId {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
        let unblockUserAction = UIAlertAction(title: "Unblock user", style: UIAlertActionStyle.Destructive) { (action) in
            SBDMain.unblockUser(user, completionHandler: { (error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.Alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(closeAction)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                else {
                    let alert = UIAlertController(title: "User Unblocked", message: String(format: "%@ is unblocked", user.nickname!), preferredStyle: UIAlertControllerStyle.Alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(closeAction)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    
                    self.blockedUsers.removeAtIndex(userIndex)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            })
        }
        
        alert.addAction(closeAction)
        alert.addAction(unblockUserAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockedUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = self.blockedUsers[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(false)
        
        if self.blockedUsers.count > 0 {
            if indexPath.row == self.blockedUsers.count - 1 {
                self.loadBlockedUsers()
            }
        }
        
        return cell
    }
}
