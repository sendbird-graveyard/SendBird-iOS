//
//  MemberListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MemberListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var channel: SBDGroupChannel?
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var query: SBDUserListQuery?
    fileprivate var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Members"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(MemberListViewController.refreshMembers), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.refreshMembers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshMembers() {
        self.refreshControl?.beginRefreshing()
        self.channel?.refresh(completionHandler: { (error) in
            DispatchQueue.main.async(execute: {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
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
        let user = self.channel!.members![(indexPath as NSIndexPath).row] as! SBDUser
        
        if user.userId == SBDMain.getCurrentUser()!.userId {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
        let blockUserAction = UIAlertAction(title: "Block user", style: UIAlertActionStyle.destructive) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
                else {
                    let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blockedUser!.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
        }
        
        alert.addAction(closeAction)
        alert.addAction(blockUserAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channel!.members!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.channel!.members![(indexPath as NSIndexPath).row] as! SBDUser
        let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(true)
        
        return cell
    }
}
