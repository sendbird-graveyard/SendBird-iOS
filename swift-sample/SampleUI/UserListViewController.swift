//
//  UserListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var invitationMode: Int?
    var channel: SBDGroupChannel?

    @IBOutlet private weak var tableView: UITableView!
    private var users: NSMutableArray?
    private var userId: String?
    private var userName: String?
    
    private var userListQuery: SBDUserListQuery?
    private var selectedUsers: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "User List"
        
        self.users = NSMutableArray()
        self.selectedUsers = NSMutableDictionary()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.userListQuery = SBDMain.createAllUserListQuery()
        self.loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.invitationMode == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create Channel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserListViewController.clickCreateChannel(_:)))
        }
        else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserListViewController.clickInvite(_:)))
        }
    }
    
    private func loadUsers() {
        if self.userListQuery?.isLoading() == true {
            return
        }
        
        if self.userListQuery?.hasNext == false {
            return
        }
        
        self.userListQuery?.loadNextPageWithCompletionHandler({ (users, error) in
            if error != nil {
                return
            }
            
            if users == nil || users!.count == 0 {
                return
            }
            
            for item in users! {
                let user = item 
                if user.userId == SBDMain.getCurrentUser()!.userId {
                    continue
                }
                self.users?.addObject(user)
                self.selectedUsers![user.userId] = Int(0)
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        })
    }
    
    func clickCreateChannel(sender: AnyObject) {
        let userIds = NSMutableArray()
        
        for item in self.selectedUsers! {
            if item.value as! Int == 1 {
                userIds.addObject(item.key)
            }
        }
        
        if userIds.count > 0 {
            let alert = UIAlertController(title: "Create Group Channel", message: "Create a group channel.", preferredStyle: UIAlertControllerStyle.Alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
            let createDistinctChannelAction = UIAlertAction(title: "Create distinct channel", style: UIAlertActionStyle.Default, handler: { (action) in
                // TODO:
            })
            let createNonDistinctChannelAction = UIAlertAction(title: "Create non-distinct channel", style: UIAlertActionStyle.Default, handler: { (action) in
                // TODO:
            })
            
            alert.addAction(closeAction)
            alert.addAction(createDistinctChannelAction)
            alert.addAction(createNonDistinctChannelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Select Users", message: "You have to select users to include", preferredStyle: UIAlertControllerStyle.Alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alert.addAction(closeAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func clickInvite(sender: AnyObject) {
        let userIds = NSMutableArray()
        
        for item in self.selectedUsers! {
            if item.value as! Int == 1 {
                userIds.addObject(item.key)
            }
        }
        
        if userIds.count > 0 {
            // TODO:
        }
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
        let user = self.users?.objectAtIndex(indexPath.row) as! SBDUser
        let cellCheck = tableView.cellForRowAtIndexPath(indexPath)
        
        if self.selectedUsers?.objectForKey(user.userId)?.intValue == 0 {
            cellCheck?.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.selectedUsers?.setObject(Int(1), forKey: user.userId)
        }
        else {
            cellCheck?.accessoryType = UITableViewCellAccessoryType.None
            self.selectedUsers?.setObject(Int(0), forKey: user.userId)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = self.users?.objectAtIndex(indexPath.row) as! SBDUser
        let cell = tableView.dequeueReusableCellWithIdentifier(UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(true)
        
        if self.selectedUsers?.objectForKey(user.userId)?.intValue == 1 {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if self.users?.count > 0 {
            if indexPath.row == (self.users?.count)! - 1 {
                self.loadUsers()
            }
        }
        
        return cell
    }
}
