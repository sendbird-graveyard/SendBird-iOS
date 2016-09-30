//
//  UserListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

protocol UserListViewControllerDelegate: class {
    func didCloseUserListViewController(_ vc: UIViewController, groupChannel: SBDGroupChannel)
}

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: UserListViewControllerDelegate!
    var invitationMode: Int?
    var channel: SBDGroupChannel?

    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var users: [SBDUser] = []
    fileprivate var userId: String?
    fileprivate var userName: String?
    
    fileprivate var userListQuery: SBDUserListQuery?
    fileprivate var selectedUsers: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "User List"
        
        self.selectedUsers = NSMutableDictionary()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.userListQuery = SBDMain.createAllUserListQuery()
        self.loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.invitationMode == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create Channel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserListViewController.clickCreateChannel(_:)))
        }
        else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserListViewController.clickInvite(_:)))
        }
    }
    
    fileprivate func loadUsers() {
        if self.userListQuery?.isLoading() == true {
            return
        }
        
        if self.userListQuery?.hasNext == false {
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { (users, error) in
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
                self.users.append(user)
                self.selectedUsers![user.userId] = Int(0)
            }
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        })
    }
    
    func clickCreateChannel(_ sender: AnyObject) {
        var userIds = [String]()
        
        for item in self.selectedUsers! {
            if item.value as! Int == 1 {
                userIds.append(item.key as! String)
            }
        }
        
        if userIds.count > 0 {
            let alert = UIAlertController(title: "Create Group Channel", message: "Create a group channel.", preferredStyle: UIAlertControllerStyle.alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
            let createDistinctChannelAction = UIAlertAction(title: "Create distinct channel", style: UIAlertActionStyle.default, handler: { (action) in
                SBDGroupChannel.createChannel(withUserIds: userIds, isDistinct: true, completionHandler: { (channel, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                        return
                    }
                    
                    if self.delegate != nil {
                        self.delegate?.didCloseUserListViewController(self, groupChannel: channel!)
                    }
                    
                    DispatchQueue.main.async(execute: { 
                        self.navigationController!.popViewController(animated: false)
                    })
                })
            })
            let createNonDistinctChannelAction = UIAlertAction(title: "Create non-distinct channel", style: UIAlertActionStyle.default, handler: { (action) in
                SBDGroupChannel.createChannel(withUserIds: userIds, isDistinct: false, completionHandler: { (channel, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                        return
                    }
                    
                    if self.delegate != nil {
                        self.delegate?.didCloseUserListViewController(self, groupChannel: channel!)
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.navigationController!.popViewController(animated: false)
                    })
                })
            })
            
            alert.addAction(closeAction)
            alert.addAction(createDistinctChannelAction)
            alert.addAction(createNonDistinctChannelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Select Users", message: "You have to select users to include", preferredStyle: UIAlertControllerStyle.alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
            
            alert.addAction(closeAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func clickInvite(_ sender: AnyObject) {
        var userIds = [String]()
        
        for item in self.selectedUsers! {
            if item.value as! Int == 1 {
                userIds.append(item.key as! String)
            }
        }
        
        if userIds.count > 0 {
            self.channel?.inviteUserIds(userIds, completionHandler: { (error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                    return
                }
                
                DispatchQueue.main.async(execute: { 
                    if self.delegate != nil {
                        self.delegate?.didCloseUserListViewController(self, groupChannel: self.channel!)
                    }
                    
                    self.navigationController!.popViewController(animated: true)
                })
            })
        }
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
        let user = self.users[(indexPath as NSIndexPath).row]
        let cellCheck = tableView.cellForRow(at: indexPath)
        
        if (self.selectedUsers?.object(forKey: user.userId) as AnyObject).int32Value == 0 {
            cellCheck?.accessoryType = UITableViewCellAccessoryType.checkmark
            self.selectedUsers?.setObject(Int(1), forKey: user.userId as NSCopying)
        }
        else {
            cellCheck?.accessoryType = UITableViewCellAccessoryType.none
            self.selectedUsers?.setObject(Int(0), forKey: user.userId as NSCopying)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.users[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(true)
        
        if (self.selectedUsers?.object(forKey: user.userId) as AnyObject).int32Value == 1 {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        if self.users.count > 0 {
            if (indexPath as NSIndexPath).row == self.users.count - 1 {
                self.loadUsers()
            }
        }
        
        return cell
    }
}
