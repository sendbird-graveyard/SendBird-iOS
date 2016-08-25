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
    private var query: SBDUserListQuery?
    private var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Members"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(MemberListViewController.refreshMembers), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.refreshMembers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshMembers() {
        self.refreshControl?.beginRefreshing()
        self.channel?.refreshWithCompletionHandler({ (error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
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
        let user = self.channel!.members![indexPath.row] as! SBDUser
        
        if user.userId == SBDMain.getCurrentUser()!.userId {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
        let blockUserAction = UIAlertAction(title: "Block user", style: UIAlertActionStyle.Destructive) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    
                }
                else {
                    
                }
            })
        }
        
        alert.addAction(closeAction)
        alert.addAction(blockUserAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channel!.members!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = self.channel!.members![indexPath.row] as! SBDUser
        let cell = tableView.dequeueReusableCellWithIdentifier(UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(true)
        
        return cell
    }
}
